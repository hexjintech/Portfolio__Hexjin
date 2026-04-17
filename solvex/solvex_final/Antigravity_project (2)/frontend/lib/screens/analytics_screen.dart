import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM ANALYTICS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: _buildStatGrid(cs)),
            const SizedBox(height: 24),
            _sectionHeader('Complaint Trends (Last 7 Days)'),
            const SizedBox(height: 16),
            FadeInUp(child: _buildMockChart(cs)),
            const SizedBox(height: 24),
            _sectionHeader('Department Performance'),
            const SizedBox(height: 16),
            _buildDeptRow(cs, 'Water Dept', 0.85, Colors.blue),
            _buildDeptRow(cs, 'Electricity', 0.72, Colors.orange),
            _buildDeptRow(cs, 'Roads & Dev', 0.94, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(ColorScheme cs) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Total Reports', '1,284', Icons.assessment_outlined, cs.primary),
        _statCard('Resolved', '942', Icons.check_circle_outline, Colors.green),
        _statCard('Avg. Time', '3.2 Days', Icons.timer_outlined, Colors.orange),
        _statCard('Satisfaction', '4.8/5', Icons.star_outline, Colors.amber),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1));
  }

  Widget _buildMockChart(ColorScheme cs) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: cs.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Icon(Icons.show_chart_rounded, size: 80, color: cs.primary.withOpacity(0.2))),
    );
  }

  Widget _buildDeptRow(ColorScheme cs, String name, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 14)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 6, borderRadius: BorderRadius.circular(3)),
        ],
      ),
    );
  }
}
