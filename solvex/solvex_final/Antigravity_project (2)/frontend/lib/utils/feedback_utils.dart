import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../models/feedback_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../screens/feedback_screen.dart';

class FeedbackUtils {
  static Future<void> handleFeedbackTap(BuildContext context, Complaint complaint) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF00B2FF))),
    );

    try {
      final response = await ApiService.getComplaintFeedback(token, complaint.id);
      
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        // Feedback exists
        final feedbackData = jsonDecode(response.body);
        final feedback = FeedbackModel.fromJson(feedbackData);
        _showFeedbackDialog(context, feedback, complaint);
      } else {
        // Assume no feedback found or error, let them provide it
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeedbackScreen(complaint: complaint)),
        );
      }
    } catch (e) {
      // Close loading if error
      Navigator.of(context, rootNavigator: true).pop();
      // On error, let them go to the provide screen anyway or show error
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FeedbackScreen(complaint: complaint)),
      );
    }
  }

  static void _showFeedbackDialog(BuildContext context, FeedbackModel feedback, Complaint complaint) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF152232),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.feedback_rounded, color: Color(0xFF76FF03), size: 28),
                  const SizedBox(width: 10),
                  const Text('Submitted Feedback', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(ctx).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              _buildDetailRow('Provider Name:', feedback.personName),
              const SizedBox(height: 12),
              _buildDetailRow('Category:', feedback.category),
              const SizedBox(height: 12),
              _buildDetailRow('Issue Type:', feedback.issueType),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rating: ', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      index < feedback.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFF76FF03),
                      size: 16,
                    )),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text('Comments:', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  feedback.comment.isNotEmpty ? feedback.comment : 'No comments provided.',
                  style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text('Close'),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A', 
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)
          )
        ),
      ],
    );
  }
}
