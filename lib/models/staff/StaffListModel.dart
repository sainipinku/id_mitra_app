class StaffListModel {
  final int id;
  final String uuid;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String phone;
  final String? whatsappPhone;
  final String? address;
  final String? profilePhotoUrl;
  final String roleName;
  final int status;
  final List<String> assignedClasses;

  const StaffListModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    this.whatsappPhone,
    this.address,
    this.profilePhotoUrl,
    required this.roleName,
    required this.status,
    required this.assignedClasses,
  });

  factory StaffListModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;
    final classes = json['assigned_classes'] as List? ?? [];

    return StaffListModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      whatsappPhone: json['whatsapp_phone'],
      address: json['address'],
      profilePhotoUrl: json['profile_photo_url'],
      roleName: role?['name'] ?? '',
      status: json['status'] ?? 1,
      assignedClasses: classes.map((c) {
        if (c is Map) return c['name_withprefix']?.toString() ?? c['name']?.toString() ?? '';
        return c.toString();
      }).where((s) => s.isNotEmpty).toList(),
    );
  }
}
