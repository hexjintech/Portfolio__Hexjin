import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT SOLVEX', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            FadeInDown(
              child: Center(
                child: Image.asset('assets/icon/icon.png', height: 100),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: Text(
                'Simplifying Civil Governance',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.primary),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Solvex is a next-generation platform designed to bridge the gap between citizens and local authorities. Our mission is to empower every individual with the tools to report, track, and resolve community issues efficiently.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: cs.onSurface.withOpacity(0.7), height: 1.6),
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureRow(cs, Icons.speed_rounded, 'Real-time Tracking', 'Monitor the progress of your complaints as they happen.'),
            _buildFeatureRow(cs, Icons.security_rounded, 'Secure & Transparent', 'Every report is encrypted and tracked for accountability.'),
            _buildFeatureRow(cs, Icons.groups_rounded, 'Community Focused', 'Working together for a cleaner and safer neighborhood.'),
            const SizedBox(height: 48),
            Text('Version 1.2.0 (Build 2026.04)', style: TextStyle(color: cs.onSurface.withOpacity(0.2), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(ColorScheme cs, IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: FadeInLeft(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
