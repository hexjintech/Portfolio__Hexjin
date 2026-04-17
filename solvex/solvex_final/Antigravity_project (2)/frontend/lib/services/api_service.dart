import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'https://complaint-app-o7h3.onrender.com/api';
  static const String rootUrl = 'https://complaint-app-o7h3.onrender.com';

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    // Ensure it correctly bridges the path to the root URL
    String cleanPath = path.startsWith('/') ? path : '/$path';
    if (cleanPath.startsWith('/uploads')) {
      return '$rootUrl$cleanPath';
    }
    return path;
  }

  static Future<http.Response> register(String name, String email, String password, String role) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> resetPassword(String email, String newPassword) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );
  }

  static Future<http.Response> getCategories() async {
    return await http.get(Uri.parse('$baseUrl/categories'));
  }

  static Future<http.Response> getCitizenComplaints(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/complaints/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getAdminComplaints(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/complaints'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> updateComplaintStatus(String token, String complaintId, String status, String remarks, String assignedDept) async {
    return await http.put(
      Uri.parse('$baseUrl/complaints/$complaintId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'status': status,
        'remarks': remarks,
        'assigned_department': assignedDept,
      }),
    );
  }

  static Future<http.StreamedResponse> createComplaint(
      String token, String title, String description, int categoryId, String location, String district, String pincode, List<int>? imageBytes, String? filename) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/complaints'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId.toString();
    request.fields['location'] = location;
    request.fields['district'] = district;
    request.fields['pincode'] = pincode;

    if (imageBytes != null && filename != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename, contentType: MediaType('image', 'jpeg')));
    }

    return await request.send();
  }

  static Future<http.Response> submitFeedback(String token, Map<String, dynamic> feedbackData) async {
    return await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(feedbackData),
    );
  }

  static Future<http.Response> getAllFeedbacks(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/feedbacks'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> getComplaintFeedback(String token, String complaintId) async {
    return await http.get(
      Uri.parse('$baseUrl/feedback/$complaintId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
