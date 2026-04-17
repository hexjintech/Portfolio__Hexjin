import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(_email, _password);
      if (mounted) {
        final role = auth.user?.role ?? 'citizen';
        if (role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/citizen-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString().replaceFirst('Exception: ', ''))),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showForgotPasswordDialog() {
    String resetEmail = _email;
    String newPassword = '';
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final cs = Theme.of(context).colorScheme;
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: resetEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                      onSaved: (value) => resetEmail = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Password too short' : null,
                      onSaved: (value) => newPassword = value!,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : TextButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          formKey.currentState!.save();
                          setState(() => isLoading = true);
                          try {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            await auth.resetPassword(resetEmail, newPassword);
                            if (mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                              );
                              setState(() => isLoading = false);
                            }
                          }
                        },
                        child: const Text('Reset', style: TextStyle(color: Color(0xFF00B2FF))),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgStart = isDark ? const Color(0xFF00050A) : const Color(0xFFEFF4FB);
    final bgEnd   = isDark ? const Color(0xFF0A0F14) : const Color(0xFFD0EEFF);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgStart, bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.05),
                      blurRadius: 100,
                      spreadRadius: 50,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: cs.onSurface.withOpacity(0.6),
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                                ],
                              ),
                              child: Image.asset(
                                'assets/icon/icon.png',
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.shield_rounded, size: 80, color: cs.primary),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'SOLVEX',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                                letterSpacing: 4,
                              ),
                            ),
                            Text(
                              'REPORT. TRACK. RESOLVE.',
                              style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Citizen Email',
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.email, color: cs.primary),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                              onSaved: (value) => _email = value!,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.lock, color: cs.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) => value!.isEmpty ? 'Enter password' : null,
                              onSaved: (value) => _password = value!,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _showForgotPasswordDialog,
                                icon: Icon(Icons.lock_reset_rounded, size: 16, color: cs.onSurface.withOpacity(0.6)),
                                label: Text('Forgot Password?', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _isLoading
                                ? CircularProgressIndicator(color: cs.primary)
                                : SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: _submit,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
                                  child: Text('New Citizen? Register', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                                ),
                                Text('|', style: TextStyle(color: cs.onSurface.withOpacity(0.2))),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/admin-login'),
                                  child: Text('Admin Portal', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
