import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final List<Map<String, dynamic>> announcements = [
      {
        'title': 'Scheduled Water Maintenance',
        'desc': 'Water supply will be affected in North Zone from 10 AM to 4 PM on Sunday.',
        'date': 'Oct 12, 2026',
        'priority': 'High',
        'icon': Icons.water_drop_outlined,
      },
      {
        'title': 'New Street Light Installation',
        'desc': 'A total of 50 new LED street lights have been installed in the West Market area.',
        'date': 'Oct 11, 2026',
        'priority': 'Normal',
        'icon': Icons.streetview_rounded,
      },
      {
        'title': 'Community Cleanup Event',
        'desc': 'Join us this Saturday for a neighborhood cleanup drive. Refreshments will be provided!',
        'date': 'Oct 10, 2026',
        'priority': 'Info',
        'icon': Icons.groups_outlined,
      },
      {
        'title': 'Internet Infrastructure Upgrade',
        'desc': 'Optical fiber laying will begin tomorrow on Main St. Expect minor traffic delays.',
        'date': 'Oct 09, 2026',
        'priority': 'Normal',
        'icon': Icons.wifi_protected_setup_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('OFFICIAL ANNOUNCEMENTS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (ctx, i) => FadeInUp(
          delay: Duration(milliseconds: i * 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _getPriorityColor(announcements[i]['priority']!).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(announcements[i]['icon']!, color: _getPriorityColor(announcements[i]['priority']!), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(announcements[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    _buildPriorityBadge(announcements[i]['priority']!),
                  ],
                ),
                const SizedBox(height: 12),
                Text(announcements[i]['desc']!, style: TextStyle(color: cs.onSurface.withOpacity(0.6), height: 1.4, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: cs.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 6),
                    Text(announcements[i]['date']!, style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.redAccent;
      case 'Info': return Colors.blueAccent;
      default: return Colors.orangeAccent;
    }
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
