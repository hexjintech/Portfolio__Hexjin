import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../providers/realtime_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/feedback_utils.dart';

class TrackComplaintScreen extends StatefulWidget {
  final Complaint complaint;

  const TrackComplaintScreen({super.key, required this.complaint});

  @override
  State<TrackComplaintScreen> createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  StreamSubscription? _statusSubscription;
  late Complaint _currentComplaint;

  @override
  void initState() {
    super.initState();
    _currentComplaint = widget.complaint;

    // Listen for updates to THIS specific complaint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final realtime = Provider.of<RealtimeProvider>(context, listen: false);
      _statusSubscription = realtime.statusUpdates.listen((updatedC) {
        if (updatedC.id == _currentComplaint.id) {
          setState(() {
            _currentComplaint = updatedC;
          });
          if (updatedC.status == 'Resolved') {
            _showSuccessDialog();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => FadeIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF76FF03), size: 60),
              SizedBox(height: 16),
              Text('Issue Resolved!', textAlign: TextAlign.center),
            ],
          ),
          content: const Text(
            'The authorities have addressed your complaint. You can now provide feedback on the service.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF76FF03),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('GREAT'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Also use the list from provider as a fallback/sync mechanism
    return Consumer<RealtimeProvider>(
      builder: (context, realtime, child) {
        // Find the latest version of this complaint in the full list
        try {
          final latest = realtime.complaints.firstWhere((c) => c.id == widget.complaint.id);
          _currentComplaint = latest;
        } catch (_) {}

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon/icon.png', height: 24),
                const SizedBox(width: 10),
                const Text('Track Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
                },
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                if (_currentComplaint.imageUrl != null && _currentComplaint.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00B2FF).withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.network(
                          ApiService.resolveImageUrl(_currentComplaint.imageUrl),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            color: Colors.grey[100],
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking Updates',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                      const SizedBox(height: 24),
                      _buildTimeline(context),
                      const SizedBox(height: 32),
                      if (_currentComplaint.remarks != null && _currentComplaint.remarks!.isNotEmpty)
                        _buildRemarksCard(context),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            FeedbackUtils.handleFeedbackTap(context, _currentComplaint);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76FF03).withOpacity(0.1),
                            foregroundColor: const Color(0xFF76FF03),
                            side: const BorderSide(color: Color(0xFF76FF03)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.feedback_outlined),
                          label: const Text('FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: cs.primary.withOpacity(0.1))),
      ),
      child: FadeInDown(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint ID: #${_currentComplaint.id}',
              style: TextStyle(fontSize: 16, color: cs.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _currentComplaint.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${_currentComplaint.categoryName}',
              style: TextStyle(fontSize: 18, color: cs.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_currentComplaint.location, style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.7)))),
              ],
            ),
            if (_currentComplaint.district != null && _currentComplaint.district!.isNotEmpty || _currentComplaint.pincode != null && _currentComplaint.pincode!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_city_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${_currentComplaint.district ?? ""}${_currentComplaint.district != null && _currentComplaint.pincode != null ? " - " : ""}${_currentComplaint.pincode ?? ""}', style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.7)))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final status = _currentComplaint.status;
    
    return Column(
      children: [
        _timelineStep(
          context,
          title: 'Complaint Registered',
          subtitle: 'Your complaint has been successfully received.',
          icon: Icons.assignment_turned_in,
          isActive: true,
          isCompleted: status == 'In Progress' || status == 'Resolved' || status == 'Pending',
          showLine: true,
        ),
        _timelineStep(
          context,
          title: 'Under Review',
          subtitle: 'Authorities are reviewing and assigning your request.',
          icon: Icons.manage_search,
          isActive: status == 'Pending',
          isCompleted: status == 'In Progress' || status == 'Resolved',
          showLine: true,
        ),
        _timelineStep(
          context,
          title: 'Processing',
          subtitle: _currentComplaint.assignedDepartment != null && _currentComplaint.assignedDepartment!.isNotEmpty
              ? 'Working on it (Dept: ${_currentComplaint.assignedDepartment})'
              : 'Our team is actively working on a resolution.',
          icon: Icons.engineering,
          isActive: status == 'In Progress',
          isCompleted: status == 'Resolved',
          showLine: true,
        ),
        _timelineStep(
          context,
          title: 'Resolved',
          subtitle: 'The issue has been addressed and the ticket is closed.',
          icon: Icons.verified,
          isActive: status == 'Resolved',
          isCompleted: status == 'Resolved',
          showLine: false,
        ),
      ],
    );
  }

  Widget _timelineStep(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
    required bool showLine,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = isCompleted ? const Color(0xFF76FF03) : (isActive ? Colors.orangeAccent : Colors.white24);
    
    return FadeInLeft(
      key: ValueKey('$title-$isActive-$isCompleted'), // Key ensures animation re-triggers on status change
      duration: const Duration(milliseconds: 500),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color!.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? const Color(0xFF76FF03) : cs.onSurface.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isCompleted || isActive ? cs.onSurface : cs.onSurface.withOpacity(0.38),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: isCompleted || isActive ? cs.onSurface.withOpacity(0.7) : cs.onSurface.withOpacity(0.24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeInUp(
      child: Card(
        elevation: 0,
        color: cs.primary.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.primary.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.feedback_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Authority Remarks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _currentComplaint.remarks!,
                style: TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic, color: cs.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
