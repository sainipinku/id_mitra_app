// To parse this JSON data, do
//
//     final userDetailsModel = userDetailsModelFromJson(jsonString);

import 'dart:convert';

UserDetailsModel userDetailsModelFromJson(String str) => UserDetailsModel.fromJson(json.decode(str));

String userDetailsModelToJson(UserDetailsModel data) => json.encode(data.toJson());

class UserDetailsModel {
  bool? status;
  String? message;
  User? user;
  String? userType;

  UserDetailsModel({
    this.status,
    this.message,
    this.user,
    this.userType,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) => UserDetailsModel(
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
 // List<dynamic>? permissions;
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
  String? gstNumber;
  //String? businessNature;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  dynamic profilePic;
  List<String>? type;
  List<String>? dealsIn;
  String? profilePhotoUrl;
  String? receivedAtFormatted;
  String? receivedAt;
  String? receivedAtHuman;
  Address? address;
  Creator? creator;
  List<dynamic>? schools;

  User({
    this.id,
    this.creatorId,
    this.parentId,
    this.accountType,
   // this.permissions,
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
  //  this.businessNature,
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

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    creatorId: json["creator_id"],
    parentId: json["parent_id"],
    accountType: json["account_type"],
  //  permissions: json["permissions"] == null ? [] : List<dynamic>.from(json["permissions"]!.map((x) => x)),
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
    //businessNature: json["business_nature"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    profilePic: json["profile_pic"],
    type: json["type"] == null ? [] : List<String>.from(json["type"]!.map((x) => x)),
    dealsIn: json["deals_in"] == null ? [] : List<String>.from(json["deals_in"]!.map((x) => x)),
    profilePhotoUrl: json["profile_photo_url"],
    receivedAtFormatted: json["received_at_formatted"],
    receivedAt: json["received_at"],
    receivedAtHuman: json["received_at_human"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    schools: json["schools"] == null ? [] : List<dynamic>.from(json["schools"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "creator_id": creatorId,
    "parent_id": parentId,
    "account_type": accountType,
   // "permissions": permissions == null ? [] : List<dynamic>.from(permissions!.map((x) => x)),
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
    //"business_nature": businessNature,
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
    "schools": schools == null ? [] : List<dynamic>.from(schools!.map((x) => x)),
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
  dynamic lat;
  dynamic long;

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
