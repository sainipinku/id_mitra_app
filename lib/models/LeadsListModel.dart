// To parse this JSON data, do
//
//     final leadsListModel = leadsListModelFromJson(jsonString);

import 'dart:convert';

LeadsListModel leadsListModelFromJson(String str) => LeadsListModel.fromJson(json.decode(str));

String leadsListModelToJson(LeadsListModel data) => json.encode(data.toJson());

class LeadsListModel {
  bool? success;
  Data? data;
  String? message;

  LeadsListModel({
    this.success,
    this.data,
    this.message,
  });

  LeadsListModel copyWith({
    bool? success,
    Data? data,
    String? message,
  }) =>
      LeadsListModel(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory LeadsListModel.fromJson(Map<String, dynamic> json) => LeadsListModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  int? currentPage;
  List<Datum>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Data copyWith({
    int? currentPage,
    List<Datum>? data,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Link>? links,
    dynamic nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
  }) =>
      Data(
        currentPage: currentPage ?? this.currentPage,
        data: data ?? this.data,
        firstPageUrl: firstPageUrl ?? this.firstPageUrl,
        from: from ?? this.from,
        lastPage: lastPage ?? this.lastPage,
        lastPageUrl: lastPageUrl ?? this.lastPageUrl,
        links: links ?? this.links,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        path: path ?? this.path,
        perPage: perPage ?? this.perPage,
        prevPageUrl: prevPageUrl ?? this.prevPageUrl,
        to: to ?? this.to,
        total: total ?? this.total,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int? id;
  String? firstName;
  String? lastName;
  String? firmName;
  List<String>? phoneNumbers;
  List<String>? emailAddresses;
  List<String>? whatsappNumbers;
  String? currentBaseLocation;
  String? pincode;
  int? stateId;
  int? cityId;
  String? city;
  dynamic website;
  dynamic gstnNo;
  String? businessName;
  dynamic physicalAddress;
  List<String>? tags;
  String? notes;
  List<String>? products;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<dynamic>? moreFields;
  int? userId;
  String? leadType;
  dynamic ocrType;
  dynamic fileType;
  dynamic capturedFile;
  List<dynamic>? capturedData;
  CityRelation? state;
  CityRelation? cityRelation;
  User? user;

  Datum({
    this.id,
    this.firstName,
    this.lastName,
    this.firmName,
    this.phoneNumbers,
    this.emailAddresses,
    this.whatsappNumbers,
    this.currentBaseLocation,
    this.pincode,
    this.stateId,
    this.cityId,
    this.city,
    this.website,
    this.gstnNo,
    this.businessName,
    this.physicalAddress,
    this.tags,
    this.notes,
    this.products,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.moreFields,
    this.userId,
    this.leadType,
    this.ocrType,
    this.fileType,
    this.capturedFile,
    this.capturedData,
    this.state,
    this.cityRelation,
    this.user,
  });

  Datum copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? firmName,
    List<String>? phoneNumbers,
    List<String>? emailAddresses,
    List<String>? whatsappNumbers,
    String? currentBaseLocation,
    String? pincode,
    int? stateId,
    int? cityId,
    String? city,
    dynamic website,
    dynamic gstnNo,
    String? businessName,
    dynamic physicalAddress,
    List<String>? tags,
    String? notes,
    List<String>? products,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    List<dynamic>? moreFields,
    int? userId,
    String? leadType,
    dynamic ocrType,
    dynamic fileType,
    dynamic capturedFile,
    List<dynamic>? capturedData,
    CityRelation? state,
    CityRelation? cityRelation,
    User? user,
  }) =>
      Datum(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        firmName: firmName ?? this.firmName,
        phoneNumbers: phoneNumbers ?? this.phoneNumbers,
        emailAddresses: emailAddresses ?? this.emailAddresses,
        whatsappNumbers: whatsappNumbers ?? this.whatsappNumbers,
        currentBaseLocation: currentBaseLocation ?? this.currentBaseLocation,
        pincode: pincode ?? this.pincode,
        stateId: stateId ?? this.stateId,
        cityId: cityId ?? this.cityId,
        city: city ?? this.city,
        website: website ?? this.website,
        gstnNo: gstnNo ?? this.gstnNo,
        businessName: businessName ?? this.businessName,
        physicalAddress: physicalAddress ?? this.physicalAddress,
        tags: tags ?? this.tags,
        notes: notes ?? this.notes,
        products: products ?? this.products,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        moreFields: moreFields ?? this.moreFields,
        userId: userId ?? this.userId,
        leadType: leadType ?? this.leadType,
        ocrType: ocrType ?? this.ocrType,
        fileType: fileType ?? this.fileType,
        capturedFile: capturedFile ?? this.capturedFile,
        capturedData: capturedData ?? this.capturedData,
        state: state ?? this.state,
        cityRelation: cityRelation ?? this.cityRelation,
        user: user ?? this.user,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    firmName: json["firm_name"],
    phoneNumbers: json["phone_numbers"] == null ? [] : List<String>.from(json["phone_numbers"]!.map((x) => x)),
    emailAddresses: json["email_addresses"] == null ? [] : List<String>.from(json["email_addresses"]!.map((x) => x)),
    whatsappNumbers: json["whatsapp_numbers"] == null ? [] : List<String>.from(json["whatsapp_numbers"]!.map((x) => x)),
    currentBaseLocation: json["current_base_location"],
    pincode: json["pincode"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    city: json["city"],
    website: json["website"],
    gstnNo: json["gstn_no"],
    businessName: json["business_name"],
    physicalAddress: json["physical_address"],
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    notes: json["notes"],
    products: json["products"] == null ? [] : List<String>.from(json["products"]!.map((x) => x)),
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    moreFields: json["more_fields"] == null ? [] : List<dynamic>.from(json["more_fields"]!.map((x) => x)),
    userId: json["user_id"],
    leadType: json["lead_type"],
    ocrType: json["ocr_type"],
    fileType: json["file_type"],
    capturedFile: json["captured_file"],
    capturedData: json["captured_data"] == null ? [] : List<dynamic>.from(json["captured_data"]!.map((x) => x)),
    state: json["state"] == null ? null : CityRelation.fromJson(json["state"]),
    cityRelation: json["city_relation"] == null ? null : CityRelation.fromJson(json["city_relation"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "firm_name": firmName,
    "phone_numbers": phoneNumbers == null ? [] : List<dynamic>.from(phoneNumbers!.map((x) => x)),
    "email_addresses": emailAddresses == null ? [] : List<dynamic>.from(emailAddresses!.map((x) => x)),
    "whatsapp_numbers": whatsappNumbers == null ? [] : List<dynamic>.from(whatsappNumbers!.map((x) => x)),
    "current_base_location": currentBaseLocation,
    "pincode": pincode,
    "state_id": stateId,
    "city_id": cityId,
    "city": city,
    "website": website,
    "gstn_no": gstnNo,
    "business_name": businessName,
    "physical_address": physicalAddress,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "notes": notes,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x)),
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "more_fields": moreFields == null ? [] : List<dynamic>.from(moreFields!.map((x) => x)),
    "user_id": userId,
    "lead_type": leadType,
    "ocr_type": ocrType,
    "file_type": fileType,
    "captured_file": capturedFile,
    "captured_data": capturedData == null ? [] : List<dynamic>.from(capturedData!.map((x) => x)),
    "state": state?.toJson(),
    "city_relation": cityRelation?.toJson(),
    "user": user?.toJson(),
  };
}

class CityRelation {
  int? id;
  int? stateId;
  String? name;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  int? countryId;

  CityRelation({
    this.id,
    this.stateId,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.countryId,
  });

  CityRelation copyWith({
    int? id,
    int? stateId,
    String? name,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    int? countryId,
  }) =>
      CityRelation(
        id: id ?? this.id,
        stateId: stateId ?? this.stateId,
        name: name ?? this.name,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        countryId: countryId ?? this.countryId,
      );

  factory CityRelation.fromJson(Map<String, dynamic> json) => CityRelation(
    id: json["id"],
    stateId: json["state_id"],
    name: json["name"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    countryId: json["country_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "state_id": stateId,
    "name": name,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "country_id": countryId,
  };
}

class User {
  int? id;
  String? uuid;
  dynamic businessTypeId;
  int? countryId;
  int? stateId;
  int? cityId;
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
  dynamic profilePic;
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
  List<String>? wantAutomate;
  LiveLocation? liveLocation;
  dynamic fcmToken;
  String? registeredTimeHuman;
  String? profilePhotoUrl;

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
    this.fcmToken,
    this.registeredTimeHuman,
    this.profilePhotoUrl,
  });

  User copyWith({
    int? id,
    String? uuid,
    dynamic businessTypeId,
    int? countryId,
    int? stateId,
    int? cityId,
    String? name,
    String? lastName,
    dynamic username,
    String? email,
    dynamic referCode,
    String? address,
    String? pincode,
    dynamic emailVerifiedAt,
    dynamic emailVerifyToken,
    dynamic emailTokenValidTime,
    String? phone,
    dynamic phoneVerifiedAt,
    String? whatsappPhone,
    dynamic wphoneVerifiedAt,
    dynamic referedBy,
    dynamic gender,
    dynamic dob,
    dynamic googleId,
    dynamic facebookId,
    dynamic linkedinId,
    dynamic profilePic,
    int? walletBalance,
    int? referalBalance,
    dynamic password,
    dynamic forgetPasswordToken,
    dynamic forgetPasswordTokenExpire,
    dynamic passwordResetToken,
    dynamic passwordResetTokenExpire,
    int? status,
    dynamic g2FaSecret,
    dynamic g2FaVerifiedAt,
    int? g2FaEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    int? otp,
    DateTime? otpExpire,
    List<String>? wantAutomate,
    LiveLocation? liveLocation,
    dynamic fcmToken,
    String? registeredTimeHuman,
    String? profilePhotoUrl,
  }) =>
      User(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        businessTypeId: businessTypeId ?? this.businessTypeId,
        countryId: countryId ?? this.countryId,
        stateId: stateId ?? this.stateId,
        cityId: cityId ?? this.cityId,
        name: name ?? this.name,
        lastName: lastName ?? this.lastName,
        username: username ?? this.username,
        email: email ?? this.email,
        referCode: referCode ?? this.referCode,
        address: address ?? this.address,
        pincode: pincode ?? this.pincode,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        emailVerifyToken: emailVerifyToken ?? this.emailVerifyToken,
        emailTokenValidTime: emailTokenValidTime ?? this.emailTokenValidTime,
        phone: phone ?? this.phone,
        phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
        whatsappPhone: whatsappPhone ?? this.whatsappPhone,
        wphoneVerifiedAt: wphoneVerifiedAt ?? this.wphoneVerifiedAt,
        referedBy: referedBy ?? this.referedBy,
        gender: gender ?? this.gender,
        dob: dob ?? this.dob,
        googleId: googleId ?? this.googleId,
        facebookId: facebookId ?? this.facebookId,
        linkedinId: linkedinId ?? this.linkedinId,
        profilePic: profilePic ?? this.profilePic,
        walletBalance: walletBalance ?? this.walletBalance,
        referalBalance: referalBalance ?? this.referalBalance,
        password: password ?? this.password,
        forgetPasswordToken: forgetPasswordToken ?? this.forgetPasswordToken,
        forgetPasswordTokenExpire: forgetPasswordTokenExpire ?? this.forgetPasswordTokenExpire,
        passwordResetToken: passwordResetToken ?? this.passwordResetToken,
        passwordResetTokenExpire: passwordResetTokenExpire ?? this.passwordResetTokenExpire,
        status: status ?? this.status,
        g2FaSecret: g2FaSecret ?? this.g2FaSecret,
        g2FaVerifiedAt: g2FaVerifiedAt ?? this.g2FaVerifiedAt,
        g2FaEnabled: g2FaEnabled ?? this.g2FaEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        otp: otp ?? this.otp,
        otpExpire: otpExpire ?? this.otpExpire,
        wantAutomate: wantAutomate ?? this.wantAutomate,
        liveLocation: liveLocation ?? this.liveLocation,
        fcmToken: fcmToken ?? this.fcmToken,
        registeredTimeHuman: registeredTimeHuman ?? this.registeredTimeHuman,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      );

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
    wantAutomate: json["want_automate"] == null ? [] : List<String>.from(json["want_automate"]!.map((x) => x)),
    liveLocation: json["live_location"] == null ? null : LiveLocation.fromJson(json["live_location"]),
    fcmToken: json["fcm_token"],
    registeredTimeHuman: json["registered_time_human"],
    profilePhotoUrl: json["profile_photo_url"],
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
    "want_automate": wantAutomate == null ? [] : List<dynamic>.from(wantAutomate!.map((x) => x)),
    "live_location": liveLocation?.toJson(),
    "fcm_token": fcmToken,
    "registered_time_human": registeredTimeHuman,
    "profile_photo_url": profilePhotoUrl,
  };
}

class LiveLocation {
  String? lat;
  String? long;

  LiveLocation({
    this.lat,
    this.long,
  });

  LiveLocation copyWith({
    String? lat,
    String? long,
  }) =>
      LiveLocation(
        lat: lat ?? this.lat,
        long: long ?? this.long,
      );

  factory LiveLocation.fromJson(Map<String, dynamic> json) => LiveLocation(
    lat: json["lat"],
    long: json["long"],
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "long": long,
  };
}

class Link {
  String? url;
  String? label;
  int? page;
  bool? active;

  Link({
    this.url,
    this.label,
    this.page,
    this.active,
  });

  Link copyWith({
    String? url,
    String? label,
    int? page,
    bool? active,
  }) =>
      Link(
        url: url ?? this.url,
        label: label ?? this.label,
        page: page ?? this.page,
        active: active ?? this.active,
      );

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    page: json["page"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "page": page,
    "active": active,
  };
}
