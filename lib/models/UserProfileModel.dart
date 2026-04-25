// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileDetailsModel userProfileModelFromJson(String str) => UserProfileDetailsModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileDetailsModel data) => json.encode(data.toJson());

class UserProfileDetailsModel {
  bool? status;
  String? message;
  User? user;
  String? userType;

  UserProfileDetailsModel({
    this.status,
    this.message,
    this.user,
    this.userType,
  });

  UserProfileDetailsModel copyWith({
    bool? status,
    String? message,
    User? user,
    String? userType,
  }) =>
      UserProfileDetailsModel(
        status: status ?? this.status,
        message: message ?? this.message,
        user: user ?? this.user,
        userType: userType ?? this.userType,
      );

  factory UserProfileDetailsModel.fromJson(Map<String, dynamic> json) => UserProfileDetailsModel(
    status: json["status"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    userType: json["user_type"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user?.toJson(),
    "user_type": userType,
  };
}

class User {
  int? id;
  int? creatorId;
  dynamic parentId;
  String? accountType;
  dynamic permissions;
  String? uuid;
  String? name;
  String? firmName;
  String? email;
  String? phone;
  String? whatsappPhone;
  String? password;
  dynamic otp;
  dynamic otpExpire;
  dynamic fcmToken;
  dynamic gstNumber;
  String? businessNature;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? profilePic;
  List<String>? type;
  List<String>? dealsIn;
  String? profilePhotoUrl;
  String? receivedAtFormatted;
  String? receivedAt;
  String? receivedAtHuman;
  Address? address;
  Creator? creator;
  List<School>? schools;

  User({
    this.id,
    this.creatorId,
    this.parentId,
    this.accountType,
    this.permissions,
    this.uuid,
    this.name,
    this.firmName,
    this.email,
    this.phone,
    this.whatsappPhone,
    this.password,
    this.otp,
    this.otpExpire,
    this.fcmToken,
    this.gstNumber,
    this.businessNature,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.profilePic,
    this.type,
    this.dealsIn,
    this.profilePhotoUrl,
    this.receivedAtFormatted,
    this.receivedAt,
    this.receivedAtHuman,
    this.address,
    this.creator,
    this.schools,
  });

  User copyWith({
    int? id,
    int? creatorId,
    dynamic parentId,
    String? accountType,
    dynamic permissions,
    String? uuid,
    String? name,
    String? firmName,
    String? email,
    String? phone,
    String? whatsappPhone,
    String? password,
    dynamic otp,
    dynamic otpExpire,
    dynamic fcmToken,
    dynamic gstNumber,
    String? businessNature,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    String? profilePic,
    List<String>? type,
    List<String>? dealsIn,
    String? profilePhotoUrl,
    String? receivedAtFormatted,
    String? receivedAt,
    String? receivedAtHuman,
    Address? address,
    Creator? creator,
    List<School>? schools,
  }) =>
      User(
        id: id ?? this.id,
        creatorId: creatorId ?? this.creatorId,
        parentId: parentId ?? this.parentId,
        accountType: accountType ?? this.accountType,
        permissions: permissions ?? this.permissions,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        firmName: firmName ?? this.firmName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        whatsappPhone: whatsappPhone ?? this.whatsappPhone,
        password: password ?? this.password,
        otp: otp ?? this.otp,
        otpExpire: otpExpire ?? this.otpExpire,
        fcmToken: fcmToken ?? this.fcmToken,
        gstNumber: gstNumber ?? this.gstNumber,
        businessNature: businessNature ?? this.businessNature,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        profilePic: profilePic ?? this.profilePic,
        type: type ?? this.type,
        dealsIn: dealsIn ?? this.dealsIn,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        receivedAtFormatted: receivedAtFormatted ?? this.receivedAtFormatted,
        receivedAt: receivedAt ?? this.receivedAt,
        receivedAtHuman: receivedAtHuman ?? this.receivedAtHuman,
        address: address ?? this.address,
        creator: creator ?? this.creator,
        schools: schools ?? this.schools,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    creatorId: json["creator_id"],
    parentId: json["parent_id"],
    accountType: json["account_type"],
    permissions: json["permissions"],
    uuid: json["uuid"],
    name: json["name"],
    firmName: json["firm_name"],
    email: json["email"],
    phone: json["phone"],
    whatsappPhone: json["whatsapp_phone"],
    password: json["password"],
    otp: json["otp"],
    otpExpire: json["otp_expire"],
    fcmToken: json["fcm_token"],
    gstNumber: json["gst_number"],
    businessNature: json["business_nature"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    profilePic: json["profile_pic"],
    type: json["type"] == null || json["type"] is! List ? [] : List<String>.from((json["type"] as List).map((x) => x?.toString() ?? '')),
    dealsIn: json["deals_in"] == null || json["deals_in"] is! List ? [] : List<String>.from((json["deals_in"] as List).map((x) => x?.toString() ?? '')),
    profilePhotoUrl: json["profile_photo_url"],
    receivedAtFormatted: json["received_at_formatted"],
    receivedAt: json["received_at"],
    receivedAtHuman: json["received_at_human"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    schools: json["schools"] == null ? [] : List<School>.from(json["schools"]!.map((x) => School.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "creator_id": creatorId,
    "parent_id": parentId,
    "account_type": accountType,
    "permissions": permissions,
    "uuid": uuid,
    "name": name,
    "firm_name": firmName,
    "email": email,
    "phone": phone,
    "whatsapp_phone": whatsappPhone,
    "password": password,
    "otp": otp,
    "otp_expire": otpExpire,
    "fcm_token": fcmToken,
    "gst_number": gstNumber,
    "business_nature": businessNature,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "profile_pic": profilePic,
    "type": type == null ? [] : List<dynamic>.from(type!.map((x) => x)),
    "deals_in": dealsIn == null ? [] : List<dynamic>.from(dealsIn!.map((x) => x)),
    "profile_photo_url": profilePhotoUrl,
    "received_at_formatted": receivedAtFormatted,
    "received_at": receivedAt,
    "received_at_human": receivedAtHuman,
    "address": address?.toJson(),
    "creator": creator?.toJson(),
    "schools": schools == null ? [] : List<dynamic>.from(schools!.map((x) => x.toJson())),
  };
}

class Address {
  int? id;
  String? uuid;
  int? partnerId;
  String? address;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? countryId;
  int? stateId;
  int? cityId;
  String? pincode;
  String? lat;
  String? long;

  Address({
    this.id,
    this.uuid,
    this.partnerId,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.countryId,
    this.stateId,
    this.cityId,
    this.pincode,
    this.lat,
    this.long,
  });

  Address copyWith({
    int? id,
    String? uuid,
    int? partnerId,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? countryId,
    int? stateId,
    int? cityId,
    String? pincode,
    String? lat,
    String? long,
  }) =>
      Address(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        partnerId: partnerId ?? this.partnerId,
        address: address ?? this.address,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        countryId: countryId ?? this.countryId,
        stateId: stateId ?? this.stateId,
        cityId: cityId ?? this.cityId,
        pincode: pincode ?? this.pincode,
        lat: lat ?? this.lat,
        long: long ?? this.long,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    uuid: json["uuid"],
    partnerId: json["partner_id"],
    address: json["address"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    pincode: json["pincode"],
    lat: json["lat"],
    long: json["long"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "partner_id": partnerId,
    "address": address,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "country_id": countryId,
    "state_id": stateId,
    "city_id": cityId,
    "pincode": pincode,
    "lat": lat,
    "long": long,
  };
}

class Creator {
  int? id;
  String? uuid;
  String? role;
  int? roleId;
  String? name;
  String? email;
  String? phone;
  String? whatsappPhone;
  String? loginPin;
  int? isPinLoginActive;
  int? status;
  dynamic extraPermissions;
  dynamic removePermissions;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? profilePhotoUrl;
  String? receivedAt;

  Creator({
    this.id,
    this.uuid,
    this.role,
    this.roleId,
    this.name,
    this.email,
    this.phone,
    this.whatsappPhone,
    this.loginPin,
    this.isPinLoginActive,
    this.status,
    this.extraPermissions,
    this.removePermissions,
    this.createdAt,
    this.updatedAt,
    this.profilePhotoUrl,
    this.receivedAt,
  });

  Creator copyWith({
    int? id,
    String? uuid,
    String? role,
    int? roleId,
    String? name,
    String? email,
    String? phone,
    String? whatsappPhone,
    String? loginPin,
    int? isPinLoginActive,
    int? status,
    dynamic extraPermissions,
    dynamic removePermissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePhotoUrl,
    String? receivedAt,
  }) =>
      Creator(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        role: role ?? this.role,
        roleId: roleId ?? this.roleId,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        whatsappPhone: whatsappPhone ?? this.whatsappPhone,
        loginPin: loginPin ?? this.loginPin,
        isPinLoginActive: isPinLoginActive ?? this.isPinLoginActive,
        status: status ?? this.status,
        extraPermissions: extraPermissions ?? this.extraPermissions,
        removePermissions: removePermissions ?? this.removePermissions,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        receivedAt: receivedAt ?? this.receivedAt,
      );

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json["id"],
    uuid: json["uuid"],
    role: json["role"],
    roleId: json["role_id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    whatsappPhone: json["whatsapp_phone"],
    loginPin: json["login_pin"],
    isPinLoginActive: json["isPinLoginActive"],
    status: json["status"],
    extraPermissions: json["extra_permissions"],
    removePermissions: json["remove_permissions"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    profilePhotoUrl: json["profile_photo_url"],
    receivedAt: json["received_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "role": role,
    "role_id": roleId,
    "name": name,
    "email": email,
    "phone": phone,
    "whatsapp_phone": whatsappPhone,
    "login_pin": loginPin,
    "isPinLoginActive": isPinLoginActive,
    "status": status,
    "extra_permissions": extraPermissions,
    "remove_permissions": removePermissions,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "profile_photo_url": profilePhotoUrl,
    "received_at": receivedAt,
  };
}

class School {
  int? id;
  String? uuid;
  int? schoolAdminId;
  int? partnerId;
  String? name;
  String? schoolPrefix;
  String? folderPrefix;
  dynamic countryId;
  dynamic stateId;
  dynamic cityId;
  String? address;
  String? pincode;
  String? logoPhoto;
  int? status;
  List<StudentFormField>? studentFormFields;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? logoUrl;
  dynamic currentSession;
  SchoolStorage? schoolStorage;
  SchoolStorage? schoolStorageCapturedByCamera;

  School({
    this.id,
    this.uuid,
    this.schoolAdminId,
    this.partnerId,
    this.name,
    this.schoolPrefix,
    this.folderPrefix,
    this.countryId,
    this.stateId,
    this.cityId,
    this.address,
    this.pincode,
    this.logoPhoto,
    this.status,
    this.studentFormFields,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.logoUrl,
    this.currentSession,
    this.schoolStorage,
    this.schoolStorageCapturedByCamera,
  });

  School copyWith({
    int? id,
    String? uuid,
    int? schoolAdminId,
    int? partnerId,
    String? name,
    String? schoolPrefix,
    String? folderPrefix,
    dynamic countryId,
    dynamic stateId,
    dynamic cityId,
    String? address,
    String? pincode,
    String? logoPhoto,
    int? status,
    List<StudentFormField>? studentFormFields,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    String? logoUrl,
    dynamic currentSession,
    SchoolStorage? schoolStorage,
    SchoolStorage? schoolStorageCapturedByCamera,
  }) =>
      School(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        schoolAdminId: schoolAdminId ?? this.schoolAdminId,
        partnerId: partnerId ?? this.partnerId,
        name: name ?? this.name,
        schoolPrefix: schoolPrefix ?? this.schoolPrefix,
        folderPrefix: folderPrefix ?? this.folderPrefix,
        countryId: countryId ?? this.countryId,
        stateId: stateId ?? this.stateId,
        cityId: cityId ?? this.cityId,
        address: address ?? this.address,
        pincode: pincode ?? this.pincode,
        logoPhoto: logoPhoto ?? this.logoPhoto,
        status: status ?? this.status,
        studentFormFields: studentFormFields ?? this.studentFormFields,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        logoUrl: logoUrl ?? this.logoUrl,
        currentSession: currentSession ?? this.currentSession,
        schoolStorage: schoolStorage ?? this.schoolStorage,
        schoolStorageCapturedByCamera: schoolStorageCapturedByCamera ?? this.schoolStorageCapturedByCamera,
      );

  factory School.fromJson(Map<String, dynamic> json) => School(
    id: json["id"],
    uuid: json["uuid"],
    schoolAdminId: json["school_admin_id"],
    partnerId: json["partner_id"],
    name: json["name"],
    schoolPrefix: json["school_prefix"],
    folderPrefix: json["folder_prefix"],
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    address: json["address"],
    pincode: json["pincode"],
    logoPhoto: json["logo_photo"],
    status: json["status"],
    studentFormFields: json["student_form_fields"] == null ? [] : List<StudentFormField>.from(json["student_form_fields"]!.map((x) => StudentFormField.fromJson(x))),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    logoUrl: json["logo_url"],
    currentSession: json["current_session"],
    schoolStorage: json["school_storage"] == null ? null : SchoolStorage.fromJson(json["school_storage"]),
    schoolStorageCapturedByCamera: json["school_storage_captured_by_camera"] == null ? null : SchoolStorage.fromJson(json["school_storage_captured_by_camera"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "school_admin_id": schoolAdminId,
    "partner_id": partnerId,
    "name": name,
    "school_prefix": schoolPrefix,
    "folder_prefix": folderPrefix,
    "country_id": countryId,
    "state_id": stateId,
    "city_id": cityId,
    "address": address,
    "pincode": pincode,
    "logo_photo": logoPhoto,
    "status": status,
    "student_form_fields": studentFormFields == null ? [] : List<dynamic>.from(studentFormFields!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "logo_url": logoUrl,
    "current_session": currentSession,
    "school_storage": schoolStorage?.toJson(),
    "school_storage_captured_by_camera": schoolStorageCapturedByCamera?.toJson(),
  };
}

class SchoolStorage {
  String? studentsPhoto;
  String? documents;
  String? parentPhoto;
  String? guardianPhoto;
  String? staffPhoto;

  SchoolStorage({
    this.studentsPhoto,
    this.documents,
    this.parentPhoto,
    this.guardianPhoto,
    this.staffPhoto,
  });

  SchoolStorage copyWith({
    String? studentsPhoto,
    String? documents,
    String? parentPhoto,
    String? guardianPhoto,
    String? staffPhoto,
  }) =>
      SchoolStorage(
        studentsPhoto: studentsPhoto ?? this.studentsPhoto,
        documents: documents ?? this.documents,
        parentPhoto: parentPhoto ?? this.parentPhoto,
        guardianPhoto: guardianPhoto ?? this.guardianPhoto,
        staffPhoto: staffPhoto ?? this.staffPhoto,
      );

  factory SchoolStorage.fromJson(Map<String, dynamic> json) => SchoolStorage(
    studentsPhoto: json["students_photo"],
    documents: json["documents"],
    parentPhoto: json["parent_photo"],
    guardianPhoto: json["guardian_photo"],
    staffPhoto: json["staff_photo"],
  );

  Map<String, dynamic> toJson() => {
    "students_photo": studentsPhoto,
    "documents": documents,
    "parent_photo": parentPhoto,
    "guardian_photo": guardianPhoto,
    "staff_photo": staffPhoto,
  };
}

class StudentFormField {
  String? name;
  String? label;
  Group? group;
  GroupLabel? groupLabel;
  String? type;
  bool? required;
  int? order;

  StudentFormField({
    this.name,
    this.label,
    this.group,
    this.groupLabel,
    this.type,
    this.required,
    this.order,
  });

  StudentFormField copyWith({
    String? name,
    String? label,
    Group? group,
    GroupLabel? groupLabel,
    String? type,
    bool? required,
  }) =>
      StudentFormField(
        name: name ?? this.name,
        label: label ?? this.label,
        group: group ?? this.group,
        groupLabel: groupLabel ?? this.groupLabel,
        type: type ?? this.type,
        required: required ?? this.required,
      );

  factory StudentFormField.fromJson(Map<String, dynamic> json) => StudentFormField(
    name: json["name"],
    label: json["label"],
    group: groupValues.map[json["group"]],
    groupLabel: groupLabelValues.map[json["group_label"]],
    type: json["type"],
    required: json["required"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "label": label,
    "group": groupValues.reverse[group],
    "group_label": groupLabelValues.reverse[groupLabel],
    "type": type,
    "required": required,
  };
}

enum Group {
  ACADEMIC,
  LOGIN,
  PERSONAL
}

final groupValues = EnumValues({
  "academic": Group.ACADEMIC,
  "login": Group.LOGIN,
  "personal": Group.PERSONAL
});

enum GroupLabel {
  ACADEMIC_DETAILS,
  LOGIN_DETAILS,
  PERSONAL_DETAILS
}

final groupLabelValues = EnumValues({
  "Academic Details": GroupLabel.ACADEMIC_DETAILS,
  "Login Details": GroupLabel.LOGIN_DETAILS,
  "Personal Details": GroupLabel.PERSONAL_DETAILS
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
