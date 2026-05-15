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
    filters: json["filters"] is Map ? Filters.fromJson(json["filters"] as Map<String, dynamic>) : null,
    orders: json["orders"] is Map ? Orders.fromJson(json["orders"] as Map<String, dynamic>) : null,
    schools: json["schools"] is Map ? Employees.fromJson(json["schools"] as Map<String, dynamic>) : null,
    users: json["users"] is Map ? SchoolAdmins.fromJson(json["users"] as Map<String, dynamic>) : null,
    schoolAdmins: json["school_admins"] is Map ? SchoolAdmins.fromJson(json["school_admins"] as Map<String, dynamic>) : null,
    students: json["students"] is Map ? Employees.fromJson(json["students"] as Map<String, dynamic>) : null,
    subPartners: json["sub_partners"] is Map ? Employees.fromJson(json["sub_partners"] as Map<String, dynamic>) : null,
    employees: json["employees"] is Map ? Employees.fromJson(json["employees"] as Map<String, dynamic>) : null,
    partner: json["partner"] is Map ? Partner.fromJson(json["partner"] as Map<String, dynamic>) : null,
    period: json["period"]?.toString(),
    dateRange: json["date_range"] is Map ? DateRange.fromJson(json["date_range"] as Map<String, dynamic>) : null,
    summary: json["summary"] is Map ? Summary.fromJson(json["summary"] as Map<String, dynamic>) : null,
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
    total: json["total"] is int ? json["total"] : int.tryParse(json["total"]?.toString() ?? ''),
    active: json["active"] is int ? json["active"] : int.tryParse(json["active"]?.toString() ?? ''),
    inactive: json["inactive"] is int ? json["inactive"] : int.tryParse(json["inactive"]?.toString() ?? ''),
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
    totalOrders: json["total_orders"] is int ? json["total_orders"] : int.tryParse(json["total_orders"]?.toString() ?? ''),
    totalSchools: json["total_schools"] is int ? json["total_schools"] : int.tryParse(json["total_schools"]?.toString() ?? ''),
    totalUsers: json["total_users"] is int ? json["total_users"] : int.tryParse(json["total_users"]?.toString() ?? ''),
    totalStudents: json["total_students"] is int ? json["total_students"] : int.tryParse(json["total_students"]?.toString() ?? ''),
    totalSubPartners: json["total_sub_partners"] is int ? json["total_sub_partners"] : int.tryParse(json["total_sub_partners"]?.toString() ?? ''),
    totalEmployees: json["total_employees"] is int ? json["total_employees"] : int.tryParse(json["total_employees"]?.toString() ?? ''),
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
