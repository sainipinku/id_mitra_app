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
  final int? roleId;
  final int status;
  final List<String> assignedClasses;
  final String? dob;
  final String? fatherName;
  final String? motherName;
  final String? husbandName;
  final String? gender;
  final String? bloodGroup;
  final String? pincode;
  final String? employeeId;
  final String? nationalCode;
  final String? loginId;
  final String? dateOfJoining;

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
    this.roleId,
    required this.status,
    required this.assignedClasses,
    this.dob,
    this.fatherName,
    this.motherName,
    this.husbandName,
    this.gender,
    this.bloodGroup,
    this.pincode,
    this.employeeId,
    this.nationalCode,
    this.loginId,
    this.dateOfJoining,
  });

  /// Fix malformed URL like "https://server/.../https://cdn/.../file.jpg"
  /// Also replaces localhost URLs with production domain
  static String? _fixUrl(dynamic raw) {
    if (raw == null) return null;
    String url = raw.toString().trim();
    if (url.isEmpty) return null;
    // If multiple http(s):// found, take from the last one
    final regex = RegExp(r'https?://');
    final matches = regex.allMatches(url).toList();
    if (matches.length > 1) {
      url = url.substring(matches.last.start);
    }
    // Replace localhost/127.0.0.1 with production domain
    url = url
        .replaceAll('http://127.0.0.1:8000', 'https://idmitra.com')
        .replaceAll('http://localhost:8000', 'https://idmitra.com')
        .replaceAll('http://localhost', 'https://idmitra.com');
    return url;
  }

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
      profilePhotoUrl: _fixUrl(json['profile_photo_url']),
      roleName: role?['name'] ?? '',
      roleId: role?['id'] is int ? role!['id'] : int.tryParse(role?['id']?.toString() ?? ''),
      status: json['status'] ?? 1,
      assignedClasses: classes.map((c) {
        if (c is Map) return c['name_withprefix']?.toString() ?? c['name']?.toString() ?? '';
        return c.toString();
      }).where((s) => s.isNotEmpty).toList(),
      dob: json['dob'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      husbandName: json['husband_name'],
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      pincode: json['pincode']?.toString(),
      employeeId: json['employee_id']?.toString(),
      nationalCode: json['national_code']?.toString(),
      loginId: json['login_id'],
      dateOfJoining: json['date_of_joining'],
    );
  }
}
