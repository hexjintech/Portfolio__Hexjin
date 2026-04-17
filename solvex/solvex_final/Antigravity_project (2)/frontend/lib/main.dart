import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/realtime_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/citizen_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RealtimeProvider>(
          create: (_) => RealtimeProvider(),
          update: (_, auth, realtime) => (realtime ?? RealtimeProvider())..update(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _autoLoginFuture;
  @override
  void initState() {
    super.initState();
    _autoLoginFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (ctx, themeProvider, _) {
        return MaterialApp(
          title: 'Solvex',
      // ── Light theme (follows system light mode) ────────────────────────
      theme: FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: Color(0xFF0077B6),
          primaryContainer: Color(0xFFD0EEFF),
          secondary: Color(0xFF388E3C),
          secondaryContainer: Color(0xFFC8E6C9),
          tertiary: Color(0xFF546E7A),
          tertiaryContainer: Color(0xFFECEFF1),
          appBarColor: Color(0xFFFFFFFF),
          error: Color(0xFFB00020),
        ),
        surface: const Color(0xFFF5F9FF),
        scaffoldBackground: const Color(0xFFEFF4FB),
        useMaterial3: true,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
      // ── Dark theme (follows system dark mode) ─────────────────────────
      darkTheme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xFF00B2FF),
          primaryContainer: Color(0xFF004881),
          secondary: Color(0xFF76FF03),
          secondaryContainer: Color(0xFF2E7D32),
          tertiary: Color(0xFFCFD8DC),
          tertiaryContainer: Color(0xFF455A64),
          appBarColor: Color(0xFF0A0F14),
          error: Color(0xFFCF6679),
        ),
        surface: const Color(0xFF0C1219),
        scaffoldBackground: const Color(0xFF00050A),
        useMaterial3: true,
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
      // ── Current Active Theme Mode ──────────────────────────────────────
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          if (auth.isAuthenticated) {
            return auth.user?.role == 'admin' 
                ? const AdminDashboard() 
                : const CitizenDashboard();
          }
          return FutureBuilder(
            future: _autoLoginFuture,
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.teal),
                        SizedBox(height: 20),
                        Text('Initializing Portal...', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                );
              }
              return const LoginScreen();
            },
          );
        },
      ),
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/admin-login': (ctx) => const AdminLoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/citizen-dashboard': (ctx) => CitizenDashboard(),
        '/admin-dashboard': (ctx) => AdminDashboard(),
      },
      debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
