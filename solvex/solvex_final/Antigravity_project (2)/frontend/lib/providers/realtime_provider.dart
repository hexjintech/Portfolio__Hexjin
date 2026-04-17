import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class RealtimeProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  List<Complaint> _complaints = [];
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isLoading = false;
  
  // Stream for status updates (to show notifications)
  final StreamController<Complaint> _statusUpdateController = StreamController<Complaint>.broadcast();
  Stream<Complaint> get statusUpdates => _statusUpdateController.stream;

  // Stream for new complaints (for admin)
  final StreamController<Complaint> _newComplaintController = StreamController<Complaint>.broadcast();
  Stream<Complaint> get newComplaints => _newComplaintController.stream;

  bool get isLoading => _isLoading;
  List<Complaint> get complaints => _complaints;
  bool get isPolling => _isPolling;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (authProvider.isAuthenticated) {
      _startPolling();
    } else {
      _stopPolling();
      _complaints = [];
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      refreshData(isSilent: true);
    });
    refreshData(); // Initial fetch
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  Future<void> refreshData({bool isSilent = false}) async {
    if (_authProvider == null || !_authProvider!.isAuthenticated) return;
    final token = _authProvider!.token;
    if (token == null) return;

    if (!isSilent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = _authProvider!.user?.role == 'admin'
          ? await ApiService.getAdminComplaints(token)
          : await ApiService.getCitizenComplaints(token);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Complaint> fetchedList = data.map((j) => Complaint.fromJson(j)).toList();
        
        _diffAndNotify(fetchedList);
        
        _complaints = fetchedList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('RealtimeProvider Polling Error: $e');
    } finally {
      if (!isSilent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _diffAndNotify(List<Complaint> newList) {
    if (_complaints.isEmpty) return;

    final role = _authProvider?.user?.role;

    for (var newC in newList) {
      try {
        final oldC = _complaints.firstWhere((c) => c.id == newC.id);
        if (oldC.status != newC.status) {
          // Status changed!
          _statusUpdateController.add(newC);
        }
      } catch (e) {
        // New complaint found
        if (role == 'admin') {
          _newComplaintController.add(newC);
        }
      }
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _statusUpdateController.close();
    _newComplaintController.close();
    super.dispose();
  }
}
