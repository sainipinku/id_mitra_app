// To parse this JSON data, do
//
//     final partnerDashboardModel = partnerDashboardModelFromJson(jsonString);

import 'dart:convert';

PartnerDashboardModel partnerDashboardModelFromJson(String str) => PartnerDashboardModel.fromJson(json.decode(str));

String partnerDashboardModelToJson(PartnerDashboardModel data) => json.encode(data.toJson());

class PartnerDashboardModel {
  bool? success;
  String? message;
  Data? data;

  PartnerDashboardModel({
    this.success,
    this.message,
    this.data,
  });

  factory PartnerDashboardModel.fromJson(Map<String, dynamic> json) => PartnerDashboardModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Filters? filters;
  Orders? orders;
  Employees? schools;
  SchoolAdmins? users;
  SchoolAdmins? schoolAdmins;
  Employees? students;
  Employees? subPartners;
  Employees? employees;
  Partner? partner;
  String? period;
  DateRange? dateRange;
  Summary? summary;

  Data({
    this.filters,
    this.orders,
    this.schools,
    this.users,
    this.schoolAdmins,
    this.students,
    this.subPartners,
    this.employees,
    this.partner,
    this.period,
    this.dateRange,
    this.summary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    orders: json["orders"] == null ? null : Orders.fromJson(json["orders"]),
    schools: json["schools"] == null ? null : Employees.fromJson(json["schools"]),
    users: json["users"] == null ? null : SchoolAdmins.fromJson(json["users"]),
    schoolAdmins: json["school_admins"] == null ? null : SchoolAdmins.fromJson(json["school_admins"]),
    students: json["students"] == null ? null : Employees.fromJson(json["students"]),
    subPartners: json["sub_partners"] == null ? null : Employees.fromJson(json["sub_partners"]),
    employees: json["employees"] == null ? null : Employees.fromJson(json["employees"]),
    partner: json["partner"] == null ? null : Partner.fromJson(json["partner"]),
    period: json["period"],
    dateRange: json["date_range"] == null ? null : DateRange.fromJson(json["date_range"]),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "filters": filters?.toJson(),
    "orders": orders?.toJson(),
    "schools": schools?.toJson(),
    "users": users?.toJson(),
    "school_admins": schoolAdmins?.toJson(),
    "students": students?.toJson(),
    "sub_partners": subPartners?.toJson(),
    "employees": employees?.toJson(),
    "partner": partner?.toJson(),
    "period": period,
    "date_range": dateRange?.toJson(),
    "summary": summary?.toJson(),
  };
}

class DateRange {
  DateTime? start;
  DateTime? end;
  String? period;

  DateRange({
    this.start,
    this.end,
    this.period,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    start: json["start"] == null ? null : DateTime.parse(json["start"]),
    end: json["end"] == null ? null : DateTime.parse(json["end"]),
    period: json["period"],
  );

  Map<String, dynamic> toJson() => {
    "start": start?.toIso8601String(),
    "end": end?.toIso8601String(),
    "period": period,
  };
}

class Employees {
  int? total;
  String? active;
  String? inactive;

  Employees({
    this.total,
    this.active,
    this.inactive,
  });

  factory Employees.fromJson(Map<String, dynamic> json) => Employees(
    total: json["total"],
    active: json["active"],
    inactive: json["inactive"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "active": active,
    "inactive": inactive,
  };
}

class Filters {
  String? filter;
  DateTime? from;
  DateTime? to;

  Filters({
    this.filter,
    this.from,
    this.to,
  });

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    filter: json["filter"],
    from: json["from"] == null ? null : DateTime.parse(json["from"]),
    to: json["to"] == null ? null : DateTime.parse(json["to"]),
  );

  Map<String, dynamic> toJson() => {
    "filter": filter,
    "from": "${from!.year.toString().padLeft(4, '0')}-${from!.month.toString().padLeft(2, '0')}-${from!.day.toString().padLeft(2, '0')}",
    "to": "${to!.year.toString().padLeft(4, '0')}-${to!.month.toString().padLeft(2, '0')}-${to!.day.toString().padLeft(2, '0')}",
  };
}

class Orders {
  int? total;
  String? ordersNew;
  String? completeOrders;
  String? pendingOrders;

  Orders({
    this.total,
    this.ordersNew,
    this.completeOrders,
    this.pendingOrders,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
    total: json["total"],
    ordersNew: json["new"],
    completeOrders: json["complete_orders"],
    pendingOrders: json["pending_orders"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "new": ordersNew,
    "complete_orders": completeOrders,
    "pending_orders": pendingOrders,
  };
}

class Partner {
  int? id;
  String? name;
  String? email;

  Partner({
    this.id,
    this.name,
    this.email,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}

class SchoolAdmins {
  int? total;
  int? active;
  int? inactive;

  SchoolAdmins({
    this.total,
    this.active,
    this.inactive,
  });

  factory SchoolAdmins.fromJson(Map<String, dynamic> json) => SchoolAdmins(
    total: json["total"],
    active: json["active"],
    inactive: json["inactive"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "active": active,
    "inactive": inactive,
  };
}

class Summary {
  int? totalOrders;
  int? totalSchools;
  int? totalUsers;
  int? totalStudents;
  int? totalSubPartners;
  int? totalEmployees;

  Summary({
    this.totalOrders,
    this.totalSchools,
    this.totalUsers,
    this.totalStudents,
    this.totalSubPartners,
    this.totalEmployees,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalOrders: json["total_orders"],
    totalSchools: json["total_schools"],
    totalUsers: json["total_users"],
    totalStudents: json["total_students"],
    totalSubPartners: json["total_sub_partners"],
    totalEmployees: json["total_employees"],
  );

  Map<String, dynamic> toJson() => {
    "total_orders": totalOrders,
    "total_schools": totalSchools,
    "total_users": totalUsers,
    "total_students": totalStudents,
    "total_sub_partners": totalSubPartners,
    "total_employees": totalEmployees,
  };
}
