import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedData = json.decode(prefs.getString('userData')!);
    _token = extractedData['token'];
    _user = User(
      id: extractedData['id'].toString(),
      name: extractedData['name'],
      email: extractedData['email'],
      role: extractedData['role'],
    );
    notifyListeners();
    return true;
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService.login(email, password);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _token = responseData['token'];
      _user = User.fromJson(responseData['user']);
      
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
        'role': _user!.role,
      });
      prefs.setString('userData', userData);
      
      notifyListeners();
    } else {
      throw Exception(responseData['error'] ?? 'Login failed');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final response = await ApiService.resetPassword(email, newPassword);
    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(responseData['error'] ?? 'Failed to reset password');
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    final response = await ApiService.register(name, email, password, role);
    final responseData = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(responseData['error'] ?? 'Registration failed');
    }
    await login(email, password);
  }

  /// Register only — does NOT auto-login. Navigate to login manually after.
  Future<void> registerOnly(String name, String email, String password, String role) async {
    final response = await ApiService.register(name, email, password, role);
    final responseData = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(responseData['error'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }
}
