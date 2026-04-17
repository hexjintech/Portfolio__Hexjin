import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/glass_card.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRICING PLANS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
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
            children: [
              FadeInDown(
                child: const Text(
                  'Choose the best plan for your needs',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Transparent pricing for individuals and organizations',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 40),
              _buildPricingCard(
                context,
                title: 'BASIC',
                price: 'Free',
                features: ['5 Complaints / month', 'Standard Support', 'Basic Tracking'],
                isPopular: false,
                color: Colors.blueAccent,
                delay: 400,
              ),
              const SizedBox(height: 24),
              _buildPricingCard(
                context,
                title: 'PREMIUM',
                price: '\$9.99/mo',
                features: ['Unlimited Complaints', 'Priority Resolution', 'Real-time Notifications', 'Advanced Analytics'],
                isPopular: true,
                color: const Color(0xFF76FF03),
                delay: 600,
              ),
              const SizedBox(height: 24),
              _buildPricingCard(
                context,
                title: 'ENTERPRISE',
                price: 'Custom',
                features: ['City-wide Management', 'Dedicated Support', 'API Integration', 'Whitelabeled Portal'],
                isPopular: false,
                color: Colors.orangeAccent,
                delay: 800,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isPopular,
    required Color color,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Stack(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 2)),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
                        child: Text('POPULAR', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const Divider(height: 32, color: Colors.white10),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: color, size: 20),
                      const SizedBox(width: 12),
                      Text(f, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showPaymentSheet(context, title, price, color),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.withOpacity(0.1),
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SELECT PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
             const Positioned(
              top: 0, right: 0,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.star, color: Color(0xFF76FF03), size: 24),
              ),
            ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, String plan, String price, Color color) {
    if (price == 'Free') {
      _showSuccessDialog(context, plan);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Checkout - $plan', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Amount to pay: $price', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            
            // GPay Button
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _processGPay(context, plan);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network('https://www.gstatic.com/lamda/images/gpay_logo.png', height: 24, errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.black)),
                    const SizedBox(width: 8),
                    const Text('Pay with GPay', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('OR PAY WITH CARD', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            
            _buildTextField(Icons.credit_card, 'Card Number', '**** **** **** 4242'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(Icons.date_range, 'Expiry', '12/26')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(Icons.lock_outline, 'CVV', '***')),
              ],
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _processGPay(context, plan);
                },
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('CONFIRM PAYMENT', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: Colors.white38),
        hintStyle: const TextStyle(color: Colors.white12),
      ),
      readOnly: true,
    );
  }

  void _processGPay(BuildContext context, String plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00B2FF)),
            SizedBox(height: 16),
            Text('Processing Payment...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      _showSuccessDialog(context, plan);
    });
  }

  void _showSuccessDialog(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle_outline, color: Color(0xFF76FF03), size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$plan Plan Activated!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Your account has been upgraded successfully.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('AWESOME')),
        ],
      ),
    );
  }
}
