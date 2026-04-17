class FeedbackModel {
  final String complaintId;
  final String personName;
  final String subject;
  final String category;
  final String issueType;
  final String location;
  final String pincode;
  final String state;
  final int rating;
  final String comment;
  final String createdAt;

  FeedbackModel({
    required this.complaintId,
    required this.personName,
    required this.subject,
    required this.category,
    required this.issueType,
    required this.location,
    required this.pincode,
    required this.state,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      complaintId: json['complaint_id'] ?? '',
      personName: json['person_name'] ?? 'Unknown',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      issueType: json['issue_type'] ?? '',
      location: json['location'] ?? '',
      pincode: json['pincode'] ?? '',
      state: json['state'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
