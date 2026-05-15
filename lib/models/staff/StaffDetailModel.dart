class StaffEmergencyContact {
  final String name;
  final String phone;
  final String relation;

  const StaffEmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory StaffEmergencyContact.fromJson(Map<String, dynamic> json) =>
      StaffEmergencyContact(
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relation: json['relation'] ?? '',
      );
}

class StaffDetailModel {
  final int id;
  final String uuid;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String phone;
  final String? whatsappPhone;
  final String? fatherName;
  final String? motherName;
  final String? husbandName;
  final String? dob;
  final String? dateOfJoining;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? pincode;
  final String? employeeId;
  final String? nationalCode;
  final String? loginId;
  final String profilePhotoUrl;
  final String roleName;
  final int? roleId;
  final int status;
  final List<StaffEmergencyContact> emergencyContacts;

  const StaffDetailModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    this.whatsappPhone,
    this.fatherName,
    this.motherName,
    this.husbandName,
    this.dob,
    this.dateOfJoining,
    this.gender,
    this.bloodGroup,
    this.address,
    this.pincode,
    this.employeeId,
    this.nationalCode,
    this.loginId,
    required this.profilePhotoUrl,
    required this.roleName,
    this.roleId,
    required this.status,
    required this.emergencyContacts,
  });

  factory StaffDetailModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>?;
    final contacts = json['emergency_contacts'] as List? ?? [];
    return StaffDetailModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      whatsappPhone: json['whatsapp_phone'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      husbandName: json['husband_name'],
      dob: json['dob'],
      dateOfJoining: json['date_of_joining'],
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      address: json['address'],
      pincode: json['pincode']?.toString(),
      employeeId: json['employee_id']?.toString(),
      nationalCode: json['national_code']?.toString(),
      loginId: json['login_id'],
      profilePhotoUrl: json['profile_photo_url'] ?? '',
      roleName: role?['name'] ?? '',
      roleId: role?['id'] is int ? role!['id'] : int.tryParse(role?['id']?.toString() ?? ''),
      status: json['status'] ?? 1,
      emergencyContacts: contacts
          .map((e) => StaffEmergencyContact.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
