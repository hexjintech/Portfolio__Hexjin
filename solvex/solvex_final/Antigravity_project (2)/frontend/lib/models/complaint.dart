class Complaint {
  final String id;
  final String title;
  final String description;
  final int categoryId;
  final String categoryName;
  final String location;
  final String status;
  final String? imageUrl;
  final String? remarks;
  final String? assignedDepartment;
  final String? district;
  final String? pincode;
  final String? userName;
  final String createdAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.location,
    required this.status,
    this.imageUrl,
    this.remarks,
    this.assignedDepartment,
    this.district,
    this.pincode,
    required this.createdAt,
    this.userName,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      categoryName: json['category_name'] ?? '',
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      location: json['location'],
      status: json['status'],
      imageUrl: json['image_url'],
      remarks: json['remarks'],
      assignedDepartment: json['assigned_department'],
      district: json['district'],
      pincode: json['pincode'],
      createdAt: json['created_at'],
      userName: json['user_name'],
    );
  }
}
