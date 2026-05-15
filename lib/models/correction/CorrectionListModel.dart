class CorrectionItem {
  final int id;
  final String? studentName;
  final String? className;
  final String? profilePhotoUrl;
  final String? issue;
  final String? status;
  final String? createdAt;

  const CorrectionItem({
    required this.id,
    this.studentName,
    this.className,
    this.profilePhotoUrl,
    this.issue,
    this.status,
    this.createdAt,
  });

  factory CorrectionItem.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final classData = student?['class'] as Map<String, dynamic>?;
    return CorrectionItem(
      id: json['id'] ?? 0,
      studentName: student?['name'] ?? json['student_name'],
      className: classData?['name_withprefix'] ?? classData?['name'] ?? json['class_name'],
      profilePhotoUrl: student?['profile_photo_url'] ?? json['profile_photo_url'],
      issue: json['issue'] ?? json['description'] ?? json['note'],
      status: json['status'],
      createdAt: json['created_at'] ?? json['orderd_at'],
    );
  }
}
