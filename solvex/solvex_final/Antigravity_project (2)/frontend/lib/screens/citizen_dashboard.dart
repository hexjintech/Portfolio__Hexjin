import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import 'submit_complaint.dart';
import 'profile_screen.dart';
import 'track_complaint.dart';
import 'pricing_screen.dart';
import 'support_screen.dart';
import 'feedbacks_list_screen.dart';
import 'feedback_screen.dart';
import '../utils/feedback_utils.dart';
import 'announcements_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';
import 'faq_screen.dart';
import '../providers/realtime_provider.dart';
import '../providers/theme_provider.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> with SingleTickerProviderStateMixin {
  List<Complaint> _filteredComplaints = [];
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _statusSubscription;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Listen for real-time status updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final realtime = Provider.of<RealtimeProvider>(context, listen: false);
      _statusSubscription = realtime.statusUpdates.listen((complaint) {
        _showStatusUpdateToast(complaint);
      });
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showStatusUpdateToast(Complaint c) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: FadeInDown(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.notifications_active, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Live Update!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Your complaint "${c.title}" is now ${c.status}.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TrackComplaintScreen(complaint: c)));
                  },
                  child: const Text('TRACK', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _filterComplaints(String query, List<Complaint> all) {
    setState(() {
      _filteredComplaints = all
          .where((c) =>
              c.title.toLowerCase().contains(query.toLowerCase()) ||
              c.categoryName.toLowerCase().contains(query.toLowerCase()) ||
              c.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved': return const Color(0xFF76FF03);
      case 'In Progress': return Colors.orangeAccent;
      default: return Colors.redAccent;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electricity': return Icons.electrical_services;
      case 'water': return Icons.water_drop;
      case 'road': return Icons.add_road;
      case 'street light': return Icons.streetview;
      case 'internet': return Icons.wifi;
      default: return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fs = themeProvider.fontSizeFactor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Consumer<RealtimeProvider>(
      builder: (context, realtime, child) {
        final allComplaints = realtime.complaints;
        final displayComplaints = _searchController.text.isEmpty ? allComplaints : _filteredComplaints;
        final isLoading = realtime.isLoading && allComplaints.isEmpty;

        return Scaffold(
          drawer: _buildDrawer(),
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icon/icon.png', height: 28),
                const SizedBox(width: 10),
                const Text('SOLVEX', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white)),
              ],
            ),
            centerTitle: true,
            elevation: 0,
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
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                tooltip: 'My Profile',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                tooltip: 'Logout',
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/login');
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
          body: Container(
            color: cs.surface,
            child: Column(
              children: [
                _buildSearchBar(allComplaints),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : displayComplaints.isEmpty
                          ? Center(
                              child: FadeIn(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 80, color: Colors.grey[800]),
                                    const SizedBox(height: 16),
                                    Text('No matching complaints.', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: displayComplaints.length,
                              itemBuilder: (ctx, i) {
                                final c = displayComplaints[i];
                                return FadeInUp(
                                  duration: Duration(milliseconds: 300 + (i * 100).clamp(0, 500)),
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 4,
                                    shadowColor: Colors.black45,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) => Container(
                                            height: MediaQuery.of(context).size.height * 0.85,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                            ),
                                            child: _buildComplaintDetails(c),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundColor: _getStatusColor(c.status).withOpacity(0.15),
                                              child: Icon(_getCategoryIcon(c.categoryName), color: _getStatusColor(c.status), size: 28),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(c.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * fs), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 4),
                                                  Text(c.categoryName, style: TextStyle(color: Colors.grey[600], fontSize: 14 * fs)),
                                                  if (DateTime.now().difference(DateTime.parse(c.createdAt)).inHours < 24)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 4),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                                        child: Text('NEW', style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            if (c.imageUrl != null && c.imageUrl!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    ApiService.resolveImageUrl(c.imageUrl!),
                                                    width: 48, height: 48, fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image_outlined, size: 24, color: Colors.white24),
                                                  ),
                                                ),
                                              ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(c.status).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: _getStatusColor(c.status))
                                                  ),
                                                  child: Text(c.status, style: TextStyle(color: _getStatusColor(c.status), fontSize: 12, fontWeight: FontWeight.bold)),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(c.createdAt.split('T')[0], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SubmitComplaintScreen()));
              Provider.of<RealtimeProvider>(context, listen: false).refreshData();
            },
            icon: const Icon(Icons.add),
            label: const Text('New Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
    );
  }

  Widget _buildComplaintDetails(Complaint c) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text(c.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailRow(Icons.category, 'Category', c.categoryName),
            _detailRow(Icons.info_outline, 'Status', c.status, color: _getStatusColor(c.status)),
            _detailRow(Icons.place_outlined, 'Place', c.location),
            if (c.district != null && c.district!.isNotEmpty || c.pincode != null && c.pincode!.isNotEmpty)
              _detailRow(Icons.location_city_outlined, 'Region', '${c.district ?? ""}${c.district != null && c.pincode != null ? " - " : ""}${c.pincode ?? ""}'),
            _detailRow(Icons.date_range, 'Date', c.createdAt.split('T')[0]),
            const Divider(height: 32),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(c.description, style: const TextStyle(fontSize: 16, height: 1.4)),
            if (c.remarks != null && c.remarks!.isNotEmpty) ...[
              const Divider(height: 32),
              const Text('Authority Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00B2FF))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF00B2FF).withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00B2FF).withOpacity(0.2))),
                child: Text(c.remarks!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
              )
            ],
            if (c.imageUrl != null && c.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiService.resolveImageUrl(c.imageUrl),
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                  },
                  errorBuilder: (ctx, err, st) => Container(
                    height: 100, 
                    color: Colors.white.withOpacity(0.05), 
                    child: const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, color: Colors.white24, size: 32),
                        SizedBox(height: 8),
                        Text('Display Error (check CORS)', style: TextStyle(color: Colors.white24, fontSize: 10)),
                      ],
                    ))
                  ),
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF76FF03).withOpacity(0.1),
                  foregroundColor: const Color(0xFF76FF03),
                  side: const BorderSide(color: Color(0xFF76FF03)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  // We stay in the context so the loading dialog can be shown
                  FeedbackUtils.handleFeedbackTap(context, c);
                },
                icon: const Icon(Icons.feedback_outlined),
                label: const Text('FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B2FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TrackComplaintScreen(complaint: c)),
                  );
                },
                icon: const Icon(Icons.show_chart_rounded),
                label: const Text('TRACK PROGRESS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 15)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color ?? Colors.white))),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<Complaint> all) {
    final cs = Theme.of(context).colorScheme;
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => _filterComplaints(val, all),
          decoration: InputDecoration(
            hintText: 'Search complaints...',
            prefixIcon: Icon(Icons.search, color: cs.primary),
            filled: true,
            fillColor: cs.onSurface.withOpacity(0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final cs = Theme.of(context).colorScheme;
    final user = Provider.of<AuthProvider>(context).user;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: cs.primary),
            ),
            accountName: Text(user?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text(user?.email ?? 'user@example.com', style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerHeader('ACTIVITY'),
                _drawerItem(Icons.home_outlined, 'Dashboard', () => Navigator.pop(context)),
                _drawerItem(Icons.history_outlined, 'My History', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
                }),
                _drawerItem(Icons.payments_outlined, 'Pricing Plans', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PricingScreen()));
                }),

                const Divider(indent: 16, endIndent: 16),
                _drawerHeader('COMMUNICATION'),
                _drawerItem(Icons.campaign_outlined, 'Announcements', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementsScreen()));
                }),
                _drawerItem(Icons.notifications_none_rounded, 'Notifications', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
                }),
                _drawerItem(Icons.feedback_outlined, 'Community Board', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbacksListScreen()));
                }),

                const Divider(indent: 16, endIndent: 16),
                _drawerHeader('SUPPORT & INFO'),
                _drawerItem(Icons.help_outline_rounded, 'Help Center', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SupportScreen()));
                }),
                _drawerItem(Icons.question_answer_outlined, 'FAQs', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FAQScreen()));
                }),
                _drawerItem(Icons.info_outline_rounded, 'About Solvex', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showPlaceholder(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
