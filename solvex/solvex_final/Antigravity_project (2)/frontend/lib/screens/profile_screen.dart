import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import 'faq_screen.dart';
import 'about_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Complaint> _complaints = [];
  bool _isLoading = true;

  int get _total => _complaints.length;
  int get _inProgress =>
      _complaints.where((c) => c.status == 'In Progress').length;
  int get _resolved =>
      _complaints.where((c) => c.status == 'Resolved').length;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await ApiService.getCitizenComplaints(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _complaints = data.map((j) => Complaint.fromJson(j)).toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?.name ?? 'User';
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
              FadeInDown(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white70, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
                      },
                    ),
                    const SizedBox(width: 8),
                    // Avatar / initials button
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Greeting ─────────────────────────────────────────────
              FadeInLeft(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6), fontSize: 15, height: 1.4),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$name 👋',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats cards ───────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 180),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(
                              color: Color(0xFF4facfe)),
                        ),
                      )
                    : Row(
                        children: [
                          _statCard(
                            value: _total,
                            label: 'Total Filed',
                            color: const Color(0xFF4facfe),
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            value: _inProgress,
                            label: 'In Progress',
                            color: const Color(0xFFFFB347),
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            value: _resolved,
                            label: 'Resolved',
                            color: const Color(0xFF43E97B),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 28),

              // ── Account details card ──────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 260),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(cs, 'PERSONAL INFORMATION'),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Column(
                        children: [
                          _detailTile(
                            context: context,
                            icon: Icons.person_outline_rounded,
                            label: 'Full Name',
                            value: name,
                            iconColor: const Color(0xFF4facfe),
                          ),
                          _divider(context),
                          _detailTile(
                            context: context,
                            icon: Icons.email_outlined,
                            label: 'Login Email',
                            value: user?.email ?? '—',
                            iconColor: Colors.deepPurpleAccent,
                          ),
                          _divider(context),
                          _detailTile(
                            context: context,
                            icon: Icons.badge_outlined,
                            label: 'User ID',
                            value: user != null ? '#${user.id}' : '—',
                            iconColor: const Color(0xFF43E97B),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionHeader(cs, 'ACCOUNT SETTINGS'),
                    _settingsGroup(cs, [
                      _settingsTile(Icons.edit_outlined, 'Edit Profile', 'Update your personal info', const Color(0xFF4facfe)),
                      _settingsTile(Icons.lock_outline_rounded, 'Change Password', 'Secure your account', Colors.orangeAccent),
                      _settingsTile(Icons.notifications_active_outlined, 'Notifications', 'Manage alerts & updates', Colors.pinkAccent),
                    ]),
                    const SizedBox(height: 24),

                    _sectionHeader(cs, 'APP PREFERENCES'),
                    _settingsGroup(cs, [
                      _settingsTile(Icons.language_rounded, 'Language', 'English (United States)', Colors.blueAccent),
                      _settingsTile(Icons.text_fields_rounded, 'Font Size', 'Scale: ${(Provider.of<ThemeProvider>(context).fontSizeFactor * 100).toInt()}%', Colors.purpleAccent),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.format_size, size: 16, color: Colors.grey),
                            Expanded(
                              child: Slider(
                                value: Provider.of<ThemeProvider>(context).fontSizeFactor,
                                min: 0.8,
                                max: 1.5,
                                divisions: 7,
                                onChanged: (val) {
                                  Provider.of<ThemeProvider>(context, listen: false).setFontSizeFactor(val);
                                },
                              ),
                            ),
                            const Icon(Icons.format_size, size: 24, color: Colors.grey),
                          ],
                        ),
                      ),
                      _settingsTile(Icons.storage_rounded, 'Data & Storage', 'Manage local cache', Colors.tealAccent),
                    ]),
                    const SizedBox(height: 24),

                    _sectionHeader(cs, 'LEGAL & SUPPORT'),
                    _settingsGroup(cs, [
                      _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', const Color(0xFF43E97B)),
                      _settingsTile(Icons.description_outlined, 'Terms of Service', 'Our agreement with you', Colors.amberAccent),
                      _settingsTile(Icons.help_center_outlined, 'Contact Support', 'Get help from our team', Colors.indigoAccent),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Logout button ─────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 340),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Version 1.2.0 • Build 2026.04', style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 10)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _statCard(
      {required int value, required String label, required Color color}) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
            fontSize: 15,
            color: cs.onSurface,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
      height: 1, indent: 72, endIndent: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1));

  Widget _sectionHeader(ColorScheme cs, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: cs.primary.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsGroup(ColorScheme cs, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final i = e.key;
          final w = e.value;
          return Column(
            children: [
              w,
              if (i < children.length - 1) 
                Divider(height: 1, indent: 72, endIndent: 16, color: cs.onSurface.withOpacity(0.05)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, Color iconColor) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () => _handleSettingsTap(title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurface.withOpacity(0.3)),
    );
  }

  void _handleSettingsTap(String title) {
    Widget? screen;
    switch (title) {
      case 'Notifications':
        screen = const NotificationsScreen();
        break;
      case 'Privacy Policy':
      case 'Terms of Service':
      case 'About Solvex':
        screen = const AboutScreen();
        break;
      case 'Contact Support':
      case 'Help Center':
        screen = const FAQScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title settings coming soon!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
