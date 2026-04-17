import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final List<Map<String, String>> notifications = [
      {'title': 'Status Updated', 'desc': 'Your Electricity complaint is now In Progress.', 'time': '2h ago', 'icon': 'electrical_services'},
      {'title': 'Resolved Successfully', 'desc': 'The Water Department has cleared the blockage.', 'time': '5h ago', 'icon': 'water_drop'},
      {'title': 'New Remark Added', 'desc': 'Authority: "Technician dispatched to the location."', 'time': '1d ago', 'icon': 'info_outline'},
      {'title': 'Welcome to Solvex', 'desc': 'Thank you for joining our community governance platform.', 'time': '3d ago', 'icon': 'celebration'},
      {'title': 'Security Alert', 'desc': 'A new login was detected from a new device.', 'time': '5d ago', 'icon': 'security'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATIONS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: notifications.length,
        itemBuilder: (ctx, i) => FadeInLeft(
          delay: Duration(milliseconds: i * 50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface.withOpacity(0.05)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getIcon(notifications[i]['icon']!), color: cs.primary, size: 20),
              ),
              title: Text(notifications[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(notifications[i]['desc']!, style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
              trailing: Text(notifications[i]['time']!, style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 11)),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'electrical_services': return Icons.electrical_services;
      case 'water_drop': return Icons.water_drop;
      case 'info_outline': return Icons.info_outline;
      case 'celebration': return Icons.celebration;
      case 'security': return Icons.security;
      default: return Icons.notifications_none;
    }
  }
}
