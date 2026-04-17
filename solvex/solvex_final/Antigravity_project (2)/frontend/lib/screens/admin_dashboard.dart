import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import 'feedbacks_list_screen.dart';
import '../providers/theme_provider.dart';
import 'analytics_screen.dart';
import 'announcements_screen.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import 'notifications_screen.dart';
import '../providers/realtime_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  String _filterStatus = 'All';
  StreamSubscription? _newComplaintSubscription;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final realtime = Provider.of<RealtimeProvider>(context, listen: false);
      _newComplaintSubscription = realtime.newComplaints.listen((complaint) {
        _showNewComplaintSnackbar(complaint);
      });
    });
  }

  @override
  void dispose() {
    _newComplaintSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showNewComplaintSnackbar(Complaint c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.fiber_new, color: Colors.amberAccent),
            const SizedBox(width: 8),
            Expanded(child: Text('New complaint: "${c.title}"')),
          ],
        ),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.amberAccent,
          onPressed: () => _showManageDialog(c),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF43E97B);
      case 'In Progress':
        return const Color(0xFFFFB347);
      default:
        return Colors.redAccent;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.autorenew_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  Future<void> _quickResolve(Complaint c) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B)),
            SizedBox(width: 8),
            Text('Mark as Resolved'),
          ],
        ),
        content: Text(
            'Mark "${c.title}" as Resolved?\n\nThis will be reflected in the citizen\'s profile immediately.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF43E97B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 8),
        Text('Updating "${c.title}"...'),
      ]),
      backgroundColor: const Color(0xFF43E97B),
      duration: const Duration(seconds: 1),
    ));

    await ApiService.updateComplaintStatus(
        token, c.id, 'Resolved', c.remarks ?? 'Resolved by authority', c.assignedDepartment ?? '');
    
    if (mounted) {
      Provider.of<RealtimeProvider>(context, listen: false).refreshData(isSilent: true);
    }
  }

  void _showManageDialog(Complaint c) {
    final cs = Theme.of(context).colorScheme;
    String currentStatus = c.status;
    String remarks = c.remarks ?? '';
    String assignedDept = c.assignedDepartment ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note_rounded,
                          color: Colors.indigo, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manage Complaint #${c.id}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c.title,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Divider(height: 28),
                  const Text('Status',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cs.onSurface.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: ['Pending', 'In Progress', 'Resolved']
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Icon(_statusIcon(s),
                                      color: _statusColor(s), size: 18),
                                  const SizedBox(width: 8),
                                  Text(s),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setStateSB(() => currentStatus = val!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Remarks',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: remarks,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add authority remarks...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cs.onSurface.withOpacity(0.05),
                    ),
                    onChanged: (val) => remarks = val,
                  ),
                  const SizedBox(height: 16),
                  const Text('Assigned Department',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: assignedDept,
                    decoration: InputDecoration(
                      hintText: 'e.g. Water Department',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cs.onSurface.withOpacity(0.05),
                    ),
                    onChanged: (val) => assignedDept = val,
                  ),
                  const SizedBox(height: 16),
                  if (c.imageUrl != null && c.imageUrl!.isNotEmpty) ...[
                    const Text('Evidence provided by Citizen',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.black,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              ApiService.resolveImageUrl(c.imageUrl),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                              },
                              errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40),
                                      SizedBox(height: 8),
                                      Text('Display Error (check CORS)', style: TextStyle(color: Colors.white24, fontSize: 10)),
                                    ],
                                  )),
                            ),
                            Positioned(
                              top: 8, right: 8,
                              child: Material(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                                child: IconButton(
                                  icon: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog.fullscreen(
                                        backgroundColor: Colors.black,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            InteractiveViewer(
                                              child: Image.network(ApiService.resolveImageUrl(c.imageUrl), fit: BoxFit.contain),
                                            ),
                                            Positioned(
                                              top: 40, right: 20,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                                                onPressed: () => Navigator.of(ctx).pop(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            final token =
                                Provider.of<AuthProvider>(context, listen: false)
                                    .token;
                            await ApiService.updateComplaintStatus(
                                token!, c.id, currentStatus, remarks, assignedDept);
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Row(children: [
                                  Icon(_statusIcon(currentStatus),
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Complaint updated to $currentStatus'),
                                ]),
                                backgroundColor:
                                    _statusColor(currentStatus),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ));
                              Provider.of<RealtimeProvider>(context, listen: false).refreshData();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF152232) : cs.surfaceVariant;
    final scaffoldBg = isDark ? const Color(0xFF0D1B2A) : cs.background;

    return Consumer<RealtimeProvider>(
      builder: (context, realtime, child) {
        final complaints = realtime.complaints;
        final total = complaints.length;
        final pending = complaints.where((c) => c.status == 'Pending').length;
        final inProgress = complaints.where((c) => c.status == 'In Progress').length;
        final resolved = complaints.where((c) => c.status == 'Resolved').length;
        final filtered = _filterStatus == 'All'
            ? complaints
            : complaints.where((c) => c.status == _filterStatus).toList();

        return Scaffold(
          backgroundColor: scaffoldBg,
          drawer: _buildDrawer(),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0D1B2A) : cs.surface,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon/icon.png', height: 28),
                const SizedBox(width: 10),
                Text(
                  'Authority Dashboard',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: cs.onSurface, fontSize: 18),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: cs.onSurface.withOpacity(0.6),
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  themeProvider.toggleTheme(!isDark);
                },
              ),
              IconButton(
                icon: Icon(Icons.logout_rounded, color: cs.onSurface.withOpacity(0.6)),
                tooltip: 'Logout',
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              )
            ],
          ),
          body: realtime.isLoading && complaints.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4facfe)))
              : RefreshIndicator(
                  color: const Color(0xFF4facfe),
                  onRefresh: () => realtime.refreshData(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: FadeInDown(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complaint Overview',
                                  style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _statCard('$total', 'Total',
                                        const Color(0xFF4facfe)),
                                    const SizedBox(width: 10),
                                    _statCard('$pending', 'Pending',
                                        Colors.redAccent),
                                    const SizedBox(width: 10),
                                    _statCard('$inProgress', 'In Progress',
                                        const Color(0xFFFFB347)),
                                    const SizedBox(width: 10),
                                    _statCard('$resolved', 'Resolved',
                                        const Color(0xFF43E97B)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['All', 'Pending', 'In Progress', 'Resolved']
                                  .map((s) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Text(s),
                                          selected: _filterStatus == s,
                                          onSelected: (_) =>
                                              setState(() => _filterStatus = s),
                                          selectedColor: const Color(0xFF4facfe),
                                          labelStyle: TextStyle(
                                            color: _filterStatus == s
                                                ? Colors.white
                                                : cs.onSurface.withOpacity(0.7),
                                            fontWeight: _filterStatus == s
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          backgroundColor: isDark 
                                              ? const Color(0xFF152232) 
                                              : cs.onSurface.withOpacity(0.05),
                                          side: BorderSide.none,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      filtered.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 72,
                                        color: cs.onSurface.withOpacity(0.2)),
                                    const SizedBox(height: 12),
                                    Text('No $_filterStatus complaints',
                                        style: TextStyle(
                                            color: cs.onSurface.withOpacity(0.4), fontSize: 16)),
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) {
                                    final c = filtered[i];
                                    return FadeInUp(
                                      duration: Duration(
                                          milliseconds:
                                              200 + (i * 60).clamp(0, 400)),
                                      child: _complaintCard(c),
                                    );
                                  },
                                  childCount: filtered.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _complaintCard(Complaint c) {
    final cs = Theme.of(context).colorScheme;
    final isResolved = c.status == 'Resolved';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF152232) : cs.surfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _statusColor(c.status).withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.title,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(c.status),
              ],
            ),
            const SizedBox(height: 12),
            if (c.imageUrl != null && c.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.black12,
                  child: Image.network(
                    ApiService.resolveImageUrl(c.imageUrl),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black26,
                      child: Center(child: Icon(Icons.broken_image_outlined, color: cs.onSurface.withOpacity(0.2))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _metaRow(Icons.person_outline, c.userName ?? 'Unknown'),
            const SizedBox(height: 4),
            _metaRow(Icons.place_outlined, c.location),
            if (c.district != null && c.district!.isNotEmpty || c.pincode != null && c.pincode!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _metaRow(Icons.location_city_outlined, '${c.district ?? ""}${c.district != null && c.pincode != null ? " - " : ""}${c.pincode ?? ""}'),
            ],
            const SizedBox(height: 4),
            _metaRow(Icons.calendar_today_outlined,
                c.createdAt.split('T')[0]),
            if (c.remarks != null && c.remarks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notes_rounded,
                        color: cs.onSurface.withOpacity(0.4), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c.remarks!,
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface.withOpacity(0.7),
                      side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text('Manage',
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.8))),
                    onPressed: () => _showManageDialog(c),
                  ),
                ),
                if (!isResolved) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF43E97B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Resolve',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      onPressed: () => _quickResolve(c),
                    ),
                  ),
                ],
                if (isResolved) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43E97B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF43E97B).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Color(0xFF43E97B), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Completed',
                            style: TextStyle(
                                color: Color(0xFF43E97B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _statusColor(status).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), color: _statusColor(status), size: 12),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: _statusColor(status),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 13, color: cs.onSurface.withOpacity(0.4)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style:
                  TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF152232) : cs.surfaceVariant;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).user;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : cs.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF152232) : cs.primaryContainer,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.indigo),
            ),
            accountName: Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(user?.email ?? 'admin@example.com'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerHeader('CORE'),
                _drawerItem(Icons.dashboard_outlined, 'Authority Dashboard', () => Navigator.pop(context)),
                _drawerItem(Icons.feedback_outlined, 'Citizen Feedbacks', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbacksListScreen()));
                }),
                const Divider(indent: 16, endIndent: 16),
                _drawerHeader('MANAGEMENT'),
                _drawerItem(Icons.business_outlined, 'Departments', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                }),
                _drawerItem(Icons.people_alt_outlined, 'Staff Overview', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                }),
                _drawerItem(Icons.assignment_ind_outlined, 'Duty Roster', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                }),
                const Divider(indent: 16, endIndent: 16),
                _drawerHeader('INSIGHTS & REPORTS'),
                _drawerItem(Icons.analytics_outlined, 'Deep Analytics', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                }),
                _drawerItem(Icons.summarize_outlined, 'Monthly Summary', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                }),
                const Divider(indent: 16, endIndent: 16),
                _drawerHeader('SYSTEM'),
                _drawerItem(Icons.settings_suggest_outlined, 'Configuration', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen()));
                }),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          _drawerItem(Icons.logout_rounded, 'Logout', () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.of(context).pushReplacementNamed('/login');
          }, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: color ?? cs.primary),
      title: Text(title, style: TextStyle(color: color ?? cs.onSurface, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }
}
