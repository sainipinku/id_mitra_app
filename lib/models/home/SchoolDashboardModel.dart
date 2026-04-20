import 'dart:convert';

SchoolDashboardModel schoolDashboardModelFromJson(String str) =>
    SchoolDashboardModel.fromJson(json.decode(str));

class SchoolDashboardModel {
  final bool success;
  final String message;
  final SchoolDashboardData data;

  SchoolDashboardModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SchoolDashboardModel.fromJson(Map<String, dynamic> json) =>
      SchoolDashboardModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: SchoolDashboardData.fromJson(json['data'] ?? {}),
      );
}

class SchoolDashboardData {
  final DashSummary summary;
  final DashAttendance attendance;
  final DashSchool? school;
  final DashSession? currentSession;
  final DashRecentActivity recentActivity;
  final DashUser? user;

  SchoolDashboardData({
    required this.summary,
    required this.attendance,
    this.school,
    this.currentSession,
    required this.recentActivity,
    this.user,
  });

  factory SchoolDashboardData.fromJson(Map<String, dynamic> json) =>
      SchoolDashboardData(
        summary: DashSummary.fromJson(json['summary'] ?? {}),
        attendance: DashAttendance.fromJson(json['attendance'] ?? {}),
        school: json['school'] != null ? DashSchool.fromJson(json['school']) : null,
        currentSession: json['current_session'] != null
            ? DashSession.fromJson(json['current_session'])
            : null,
        recentActivity: DashRecentActivity.fromJson(json['recent_activity'] ?? {}),
        user: json['user'] != null ? DashUser.fromJson(json['user']) : null,
      );
}

class DashSummary {
  final DashOrders orders;
  final int students;
  final int staff;
  final int classes;
  final int checklists;

  DashSummary({
    required this.orders,
    required this.students,
    required this.staff,
    required this.classes,
    required this.checklists,
  });

  factory DashSummary.fromJson(Map<String, dynamic> json) {
    final o = json['orders'] ?? {};
    final s = json['students'] ?? {};
    final st = json['staff'] ?? {};
    final cl = json['classes'] ?? {};
    final ch = json['checklists'] ?? {};
    return DashSummary(
      orders: DashOrders.fromJson(o),
      students: _parseInt(s['total']),
      staff: _parseInt(st['total']),
      classes: _parseInt(cl['total']),
      checklists: _parseInt(ch['total']),
    );
  }
}

class DashOrders {
  final int total;
  final int newOrders;
  final int completed;
  final int pending;

  DashOrders({
    required this.total,
    required this.newOrders,
    required this.completed,
    required this.pending,
  });

  factory DashOrders.fromJson(Map<String, dynamic> json) => DashOrders(
        total: _parseInt(json['total']),
        newOrders: _parseInt(json['new']),
        completed: _parseInt(json['completed']),
        pending: _parseInt(json['pending']),
      );
}

class DashAttendance {
  final bool hasAttendance;
  final String message;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final int total;
  final double attendancePercentage;
  final String attendanceDate;

  DashAttendance({
    required this.hasAttendance,
    required this.message,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.total,
    required this.attendancePercentage,
    required this.attendanceDate,
  });

  factory DashAttendance.fromJson(Map<String, dynamic> json) => DashAttendance(
        hasAttendance: json['has_attendance'] ?? false,
        message: json['message'] ?? '',
        present: _parseInt(json['present']),
        absent: _parseInt(json['absent']),
        late: _parseInt(json['late']),
        leave: _parseInt(json['leave']),
        total: _parseInt(json['total']),
        attendancePercentage: _parseDouble(json['attendance_percentage']),
        attendanceDate: json['attendance_date'] ?? '',
      );
}

class DashSchool {
  final int id;
  final String name;
  final String schoolPrefix;
  final String logoUrl;

  DashSchool({
    required this.id,
    required this.name,
    required this.schoolPrefix,
    required this.logoUrl,
  });

  factory DashSchool.fromJson(Map<String, dynamic> json) => DashSchool(
        id: _parseInt(json['id']),
        name: json['name'] ?? '',
        schoolPrefix: json['school_prefix'] ?? '',
        logoUrl: json['logo_url'] ?? '',
      );
}

class DashSession {
  final String name;
  final String start;
  final String end;

  DashSession({required this.name, required this.start, required this.end});

  factory DashSession.fromJson(Map<String, dynamic> json) => DashSession(
        name: json['name'] ?? '',
        start: json['start'] ?? '',
        end: json['end'] ?? '',
      );
}

class DashRecentActivity {
  final List<DashRecentOrder> orders;
  final List<DashRecentStudent> students;

  DashRecentActivity({required this.orders, required this.students});

  factory DashRecentActivity.fromJson(Map<String, dynamic> json) =>
      DashRecentActivity(
        orders: (json['orders'] as List? ?? [])
            .map((e) => DashRecentOrder.fromJson(e))
            .toList(),
        students: (json['students'] as List? ?? [])
            .map((e) => DashRecentStudent.fromJson(e))
            .toList(),
      );
}

class DashRecentOrder {
  final int id;
  final String status;
  final String createdAt;

  DashRecentOrder({required this.id, required this.status, required this.createdAt});

  factory DashRecentOrder.fromJson(Map<String, dynamic> json) => DashRecentOrder(
        id: _parseInt(json['id']),
        status: json['status'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}

class DashRecentStudent {
  final int id;
  final String name;
  final String? profilePhotoUrl;
  final String createdAt;

  DashRecentStudent({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  factory DashRecentStudent.fromJson(Map<String, dynamic> json) => DashRecentStudent(
        id: _parseInt(json['id']),
        name: json['name'] ?? '',
        profilePhotoUrl: json['profile_photo_url'],
        createdAt: json['created_at'] ?? '',
      );
}

class DashUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profilePhotoUrl;

  DashUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.profilePhotoUrl,
  });

  factory DashUser.fromJson(Map<String, dynamic> json) => DashUser(
        id: _parseInt(json['id']),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: json['role'] ?? '',
        profilePhotoUrl: json['profile_photo_url'] ?? '',
      );
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

double _parseDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
