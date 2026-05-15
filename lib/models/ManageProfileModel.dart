// To parse this JSON data, do
//
//     final manageProfileDataModel = manageProfileDataModelFromJson(jsonString);

import 'dart:convert';

ManageProfileDataModel manageProfileDataModelFromJson(String str) => ManageProfileDataModel.fromJson(json.decode(str));

String manageProfileDataModelToJson(ManageProfileDataModel data) => json.encode(data.toJson());

class ManageProfileDataModel {
  bool? status;
  String? message;
  User? user;
  List<dynamic>? firmImages;
  ManageProfileDataModelBusinessDetail? businessDetail;

  ManageProfileDataModel({
    this.status,
    this.message,
    this.user,
    this.firmImages,
    this.businessDetail,
  });

  factory ManageProfileDataModel.fromJson(Map<String, dynamic> json) => ManageProfileDataModel(
    status: json["status"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    firmImages: json["firm_images"] == null ? [] : List<dynamic>.from(json["firm_images"]!.map((x) => x)),
    businessDetail: json["business_detail"] == null ? null : ManageProfileDataModelBusinessDetail.fromJson(json["business_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user?.toJson(),
    "firm_images": firmImages == null ? [] : List<dynamic>.from(firmImages!.map((x) => x)),
    "business_detail": businessDetail?.toJson(),
  };
}

class ManageProfileDataModelBusinessDetail {
  int? id;
  int? userId;
  String? firmName;
  String? businessTypeId;
  String? businessEmail;
  dynamic businessLocation;
  String? businessAddress;
  dynamic businessDescription;
  dynamic logo;
  dynamic deals;
  dynamic extra;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic website;
  dynamic gstNo;

  ManageProfileDataModelBusinessDetail({
    this.id,
    this.userId,
    this.firmName,
    this.businessTypeId,
    this.businessEmail,
    this.businessLocation,
    this.businessAddress,
    this.businessDescription,
    this.logo,
    this.deals,
    this.extra,
    this.createdAt,
    this.updatedAt,
    this.website,
    this.gstNo,
  });

  factory ManageProfileDataModelBusinessDetail.fromJson(Map<String, dynamic> json) => ManageProfileDataModelBusinessDetail(
    id: json["id"],
    userId: json["user_id"],
    firmName: json["firm_name"],
    businessTypeId: json["business_type_id"],
    businessEmail: json["business_email"],
    businessLocation: json["business_location"],
    businessAddress: json["business_address"],
    businessDescription: json["business_description"],
    logo: json["logo"],
    deals: json["deals"],
    extra: json["extra"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    website: json["website"],
    gstNo: json["gst_no"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "firm_name": firmName,
    "business_type_id": businessTypeId,
    "business_email": businessEmail,
    "business_location": businessLocation,
    "business_address": businessAddress,
    "business_description": businessDescription,
    "logo": logo,
    "deals": deals,
    "extra": extra,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "website": website,
    "gst_no": gstNo,
  };
}

class User {
  int? id;
  String? uuid;
  dynamic businessTypeId;
  String? countryId;
  String? stateId;
  String? cityId;
  String? name;
  String? lastName;
  dynamic username;
  String? email;
  dynamic referCode;
  String? address;
  String? pincode;
  dynamic emailVerifiedAt;
  dynamic emailVerifyToken;
  dynamic emailTokenValidTime;
  String? phone;
  dynamic phoneVerifiedAt;
  String? whatsappPhone;
  dynamic wphoneVerifiedAt;
  dynamic referedBy;
  dynamic gender;
  dynamic dob;
  dynamic googleId;
  dynamic facebookId;
  dynamic linkedinId;
  String? profilePic;
  int? walletBalance;
  int? referalBalance;
  dynamic password;
  dynamic forgetPasswordToken;
  dynamic forgetPasswordTokenExpire;
  dynamic passwordResetToken;
  dynamic passwordResetTokenExpire;
  int? status;
  dynamic g2FaSecret;
  dynamic g2FaVerifiedAt;
  int? g2FaEnabled;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? otp;
  DateTime? otpExpire;
  dynamic wantAutomate;
  dynamic liveLocation;
  String? registeredTimeHuman;
  String? profilePhotoUrl;
  List<FirmImage>? firmImages;
  UserBusinessDetail? businessDetail;

  User({
    this.id,
    this.uuid,
    this.businessTypeId,
    this.countryId,
    this.stateId,
    this.cityId,
    this.name,
    this.lastName,
    this.username,
    this.email,
    this.referCode,
    this.address,
    this.pincode,
    this.emailVerifiedAt,
    this.emailVerifyToken,
    this.emailTokenValidTime,
    this.phone,
    this.phoneVerifiedAt,
    this.whatsappPhone,
    this.wphoneVerifiedAt,
    this.referedBy,
    this.gender,
    this.dob,
    this.googleId,
    this.facebookId,
    this.linkedinId,
    this.profilePic,
    this.walletBalance,
    this.referalBalance,
    this.password,
    this.forgetPasswordToken,
    this.forgetPasswordTokenExpire,
    this.passwordResetToken,
    this.passwordResetTokenExpire,
    this.status,
    this.g2FaSecret,
    this.g2FaVerifiedAt,
    this.g2FaEnabled,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.otp,
    this.otpExpire,
    this.wantAutomate,
    this.liveLocation,
    this.registeredTimeHuman,
    this.profilePhotoUrl,
    this.firmImages,
    this.businessDetail,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    uuid: json["uuid"],
    businessTypeId: json["business_type_id"],
    countryId: json["country_id"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    name: json["name"],
    lastName: json["last_name"],
    username: json["username"],
    email: json["email"],
    referCode: json["refer_code"],
    address: json["address"],
    pincode: json["pincode"],
    emailVerifiedAt: json["email_verified_at"],
    emailVerifyToken: json["email_verify_token"],
    emailTokenValidTime: json["email_token_valid_time"],
    phone: json["phone"],
    phoneVerifiedAt: json["phone_verified_at"],
    whatsappPhone: json["whatsapp_phone"],
    wphoneVerifiedAt: json["wphone_verified_at"],
    referedBy: json["refered_by"],
    gender: json["gender"],
    dob: json["dob"],
    googleId: json["google_id"],
    facebookId: json["facebook_id"],
    linkedinId: json["linkedin_id"],
    profilePic: json["profile_pic"],
    walletBalance: json["wallet_balance"],
    referalBalance: json["referal_balance"],
    password: json["password"],
    forgetPasswordToken: json["forget_password_token"],
    forgetPasswordTokenExpire: json["forget_password_token_expire"],
    passwordResetToken: json["password_reset_token"],
    passwordResetTokenExpire: json["password_reset_token_expire"],
    status: json["status"],
    g2FaSecret: json["g2fa_secret"],
    g2FaVerifiedAt: json["g2fa_verified_at"],
    g2FaEnabled: json["g2fa_enabled"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    otp: json["otp"],
    otpExpire: json["otp_expire"] == null ? null : DateTime.parse(json["otp_expire"]),
    wantAutomate: json["want_automate"],
    liveLocation: json["live_location"],
    registeredTimeHuman: json["registered_time_human"],
    profilePhotoUrl: json["profile_photo_url"],
    firmImages: json["firm_images"] == null ? [] : List<FirmImage>.from(json["firm_images"]!.map((x) => FirmImage.fromJson(x))),
    businessDetail: json["business_detail"] == null ? null : UserBusinessDetail.fromJson(json["business_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "business_type_id": businessTypeId,
    "country_id": countryId,
    "state_id": stateId,
    "city_id": cityId,
    "name": name,
    "last_name": lastName,
    "username": username,
    "email": email,
    "refer_code": referCode,
    "address": address,
    "pincode": pincode,
    "email_verified_at": emailVerifiedAt,
    "email_verify_token": emailVerifyToken,
    "email_token_valid_time": emailTokenValidTime,
    "phone": phone,
    "phone_verified_at": phoneVerifiedAt,
    "whatsapp_phone": whatsappPhone,
    "wphone_verified_at": wphoneVerifiedAt,
    "refered_by": referedBy,
    "gender": gender,
    "dob": dob,
    "google_id": googleId,
    "facebook_id": facebookId,
    "linkedin_id": linkedinId,
    "profile_pic": profilePic,
    "wallet_balance": walletBalance,
    "referal_balance": referalBalance,
    "password": password,
    "forget_password_token": forgetPasswordToken,
    "forget_password_token_expire": forgetPasswordTokenExpire,
    "password_reset_token": passwordResetToken,
    "password_reset_token_expire": passwordResetTokenExpire,
    "status": status,
    "g2fa_secret": g2FaSecret,
    "g2fa_verified_at": g2FaVerifiedAt,
    "g2fa_enabled": g2FaEnabled,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "otp": otp,
    "otp_expire": otpExpire?.toIso8601String(),
    "want_automate": wantAutomate,
    "live_location": liveLocation,
    "registered_time_human": registeredTimeHuman,
    "profile_photo_url": profilePhotoUrl,
    "firm_images": firmImages == null ? [] : List<dynamic>.from(firmImages!.map((x) => x.toJson())),
    "business_detail": businessDetail?.toJson(),
  };
}

class UserBusinessDetail {
  int? id;
  int? userId;
  String? firmName;
  int? businessTypeId;
  String? businessEmail;
  dynamic businessLocation;
  String? businessAddress;
  dynamic businessDescription;
  dynamic logo;
  dynamic deals;
  dynamic extra;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic website;
  dynamic gstNo;
  List<FirmImage>? firmImages;

  UserBusinessDetail({
    this.id,
    this.userId,
    this.firmName,
    this.businessTypeId,
    this.businessEmail,
    this.businessLocation,
    this.businessAddress,
    this.businessDescription,
    this.logo,
    this.deals,
    this.extra,
    this.createdAt,
    this.updatedAt,
    this.website,
    this.gstNo,
    this.firmImages,
  });

  factory UserBusinessDetail.fromJson(Map<String, dynamic> json) => UserBusinessDetail(
    id: json["id"],
    userId: json["user_id"],
    firmName: json["firm_name"],
    businessTypeId: json["business_type_id"],
    businessEmail: json["business_email"],
    businessLocation: json["business_location"],
    businessAddress: json["business_address"],
    businessDescription: json["business_description"],
    logo: json["logo"],
    deals: json["deals"],
    extra: json["extra"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    website: json["website"],
    gstNo: json["gst_no"],
    firmImages: json["firm_images"] == null ? [] : List<FirmImage>.from(json["firm_images"]!.map((x) => FirmImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "firm_name": firmName,
    "business_type_id": businessTypeId,
    "business_email": businessEmail,
    "business_location": businessLocation,
    "business_address": businessAddress,
    "business_description": businessDescription,
    "logo": logo,
    "deals": deals,
    "extra": extra,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "website": website,
    "gst_no": gstNo,
    "firm_images": firmImages == null ? [] : List<dynamic>.from(firmImages!.map((x) => x.toJson())),
  };
}

class FirmImage {
  int? id;
  int? userId;
  int? userBusinessDetailId;
  String? image;
  String? fileType;
  String? mimeType;
  dynamic caption;
  int? sortOrder;
  bool? isPrimary;
  DateTime? createdAt;
  DateTime? updatedAt;

  FirmImage({
    this.id,
    this.userId,
    this.userBusinessDetailId,
    this.image,
    this.fileType,
    this.mimeType,
    this.caption,
    this.sortOrder,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  factory FirmImage.fromJson(Map<String, dynamic> json) => FirmImage(
    id: json["id"],
    userId: json["user_id"],
    userBusinessDetailId: json["user_business_detail_id"],
    image: json["image"],
    fileType: json["file_type"],
    mimeType: json["mime_type"],
    caption: json["caption"],
    sortOrder: json["sort_order"],
    isPrimary: json["is_primary"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "user_business_detail_id": userBusinessDetailId,
    "image": image,
    "file_type": fileType,
    "mime_type": mimeType,
    "caption": caption,
    "sort_order": sortOrder,
    "is_primary": isPrimary,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
