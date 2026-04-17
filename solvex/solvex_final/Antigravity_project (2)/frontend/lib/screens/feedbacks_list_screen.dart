import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/feedback_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'feedback_screen.dart';
import '../providers/theme_provider.dart';

class FeedbacksListScreen extends StatefulWidget {
  const FeedbacksListScreen({super.key});

  @override
  State<FeedbacksListScreen> createState() => _FeedbacksListScreenState();
}

class _FeedbacksListScreenState extends State<FeedbacksListScreen> {
  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    
    try {
      final response = await ApiService.getAllFeedbacks(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _feedbacks = data.map((json) => FeedbackModel.fromJson(json)).toList();
        });
      } else {
        throw Exception("API rejected request (Render Backend needs update)");
      }
    } catch (e) {
      // Fallback to sample data if Render hasn't been updated yet
      if (mounted) {
        setState(() {
          _feedbacks = [
            FeedbackModel(
              complaintId: "c1",
              personName: "Rahul Sharma (Mock Data)",
              subject: "Need more benches",
              category: "Education and learning",
              issueType: "Poor Facilities",
              location: "Main Campus",
              pincode: "600001",
              state: "Tamil Nadu",
              rating: 4,
              comment: "The new upgrades were helpful but more benches are needed.",
              createdAt: DateTime.now().toIso8601String(),
            ),
            FeedbackModel(
              complaintId: "c2",
              personName: "Priya Nair (Mock Data)",
              subject: "Power outage in area",
              category: "Electricity",
              issueType: "Power Outage",
              location: "North Block",
              pincode: "600002",
              state: "Tamil Nadu",
              rating: 5,
              comment: "Fixed very fast, thank you!",
              createdAt: DateTime.now().toIso8601String(),
            ),
          ];
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Showing mock data: Render backend not yet updated'),
            backgroundColor: Colors.orange));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Community Feedbacks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4facfe)))
        : _feedbacks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined, size: 70, color: cs.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('No feedback submitted yet.', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 16)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchFeedbacks,
              color: cs.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _feedbacks.length,
                itemBuilder: (ctx, i) {
                  final fb = _feedbacks[i];
                  return FadeInUp(
                    duration: Duration(milliseconds: 200 + (i * 60).clamp(0, 400)),
                    child: Card(
                      color: cs.surfaceVariant,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF4facfe).withOpacity(0.15),
                                  child: const Icon(Icons.person, color: Color(0xFF4facfe)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(fb.personName, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(fb.subject, style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) => Icon(
                                      index < fb.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: const Color(0xFFFFB347),
                                      size: 18,
                                  )),
                                )
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            if (fb.category.isNotEmpty)
                              _infoRow(Icons.category_outlined, '${fb.category} (${fb.issueType})'),
                            const SizedBox(height: 6),
                            if (fb.location.isNotEmpty)
                              _infoRow(Icons.location_on_outlined, fb.location),
                            const SizedBox(height: 12),
                            if (fb.comment.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.onSurface.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cs.onSurface.withOpacity(0.1))
                                ),
                                child: Text('"${fb.comment}"', style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.4)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(fb.createdAt.split('T')[0], style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackScreen()));
          _fetchFeedbacks(); // Refresh the list after returning!
        },
        backgroundColor: cs.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 14)),
        ),
      ],
    );
  }
}
