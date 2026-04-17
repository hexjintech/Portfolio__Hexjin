import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/glass_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUPPORT CENTER', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B2FF), Color(0xFF76FF03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF00050A)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: const Text('How can we help you?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              FadeInDown(delay: const Duration(milliseconds: 200), child: Text('Get in touch with our team or browse FAQs', style: TextStyle(fontSize: 16, color: Colors.grey[400]))),
              const SizedBox(height: 32),
              
              const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildContactMethod(Icons.email_outlined, 'Email', 'connect@solvex.com')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildContactMethod(Icons.phone_outlined, 'Phone', '7418528073')),
                ],
              ),
              const SizedBox(height: 16),
              _buildContactMethod(Icons.chat_bubble_outline, 'Live Chat', 'Average wait: 2 mins', isFullWidth: true),
              
              const SizedBox(height: 40),
              const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 16),
              _buildFAQItem('How do I track my complaint?', 'You can track your complaint by clicking on the "TRACK PROGRESS" button in the complaint details modal.'),
              _buildFAQItem('How long does it take to resolve?', 'Resolution time depends on the category. Most issues are addressed within 48-72 hours.'),
              _buildFAQItem('Can I edit my complaint after submission?', 'Once submitted, you can only add remarks or track progress. For major changes, please contact support.'),
              
              const SizedBox(height: 40),
              Center(
                child: FadeIn(
                  delay: const Duration(seconds: 1),
                  child: Image.asset('assets/icon/icon.png', height: 60, opacity: const AlwaysStoppedAnimation(0.2)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle, {bool isFullWidth = false}) {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00B2FF), size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ExpansionTile(
          iconColor: const Color(0xFF76FF03),
          collapsedIconColor: Colors.white54,
          title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
