class OrderModel {
  final int id;
  final String uuid;
  final String status;
  final String type;
  final String orderedAt;
  final String receivedAtShort;
  final int studentCard;
  final int studentCardQty;
  final int parentCard;
  final int admitCard;
  final String? printingIssue;
  final String? deliveredAt;
  final String? cancelledAt;
  final OrderSchool? school;
  final OrderStudent? student;

  const OrderModel({
    required this.id,
    required this.uuid,
    required this.status,
    required this.type,
    required this.orderedAt,
    required this.receivedAtShort,
    this.studentCard = 0,
    this.studentCardQty = 1,
    this.parentCard = 0,
    this.admitCard = 0,
    this.printingIssue,
    this.deliveredAt,
    this.cancelledAt,
    this.school,
    this.student,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      orderedAt: json['orderd_at'] ?? '',
      receivedAtShort: json['received_at_short'] ?? '',
      studentCard: json['student_card'] ?? 0,
      studentCardQty: json['student_card_qty'] ?? 1,
      parentCard: json['parent_card'] ?? 0,
      admitCard: json['admit_card'] ?? 0,
      printingIssue: json['printing_issue'],
      deliveredAt: json['deliverd_at'],
      cancelledAt: json['cancelled_at'],
      school: json['school'] != null ? OrderSchool.fromJson(json['school']) : null,
      student: json['student'] != null ? OrderStudent.fromJson(json['student']) : null,
    );
  }

  String get statusLabel {
    return kOrderStatuses
        .firstWhere((s) => s.value == status,
            orElse: () => OrderStatusOption(status, status.replaceAll('_', ' ')))
        .label;
  }

  String get typeLabel {
    switch (type) {
      case 'pvc_card': return 'PVC Card';
      case 'rfid_card': return 'RFID Card';
      case 'pasting_card': return 'Pasting Card';
      default: return type.replaceAll('_', ' ');
    }
  }

  String get orderCardsLabel {
    final parts = <String>[];
    if (studentCard == 1) parts.add('Student');
    if (parentCard == 1) parts.add('Parent');
    if (admitCard == 1) parts.add('Admit');
    return parts.isEmpty ? '-' : parts.join(', ');
  }
}

class OrderSchool {
  final int id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? pincode;
  final String? prefix;

  const OrderSchool({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.pincode,
    this.prefix,
  });

  factory OrderSchool.fromJson(Map<String, dynamic> json) => OrderSchool(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        logoUrl: json['logo_url'],
        address: json['address'],
        pincode: json['pincode']?.toString(),
        prefix: json['school_prefix'],
      );
}

class OrderStudent {
  final int id;
  final String name;
  final String? profilePhotoUrl;
  final String? className;
  final int? classId;
  final String? sectionName;
  final String? gender;
  final String? dob;
  final String? fatherName;
  final String? fatherPhone;
  final String? motherName;
  final String? address;
  final String? pincode;
  final String? loginId;

  const OrderStudent({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    this.className,
    this.classId,
    this.sectionName,
    this.gender,
    this.dob,
    this.fatherName,
    this.fatherPhone,
    this.motherName,
    this.address,
    this.pincode,
    this.loginId,
  });

  factory OrderStudent.fromJson(Map<String, dynamic> json) {
    final cls = json['class'] as Map<String, dynamic>?;
    final section = json['section'] as Map<String, dynamic>?;
    return OrderStudent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      className: cls?['name_withprefix'],
      classId: cls?['id'],
      sectionName: section?['name'],
      gender: json['gender'],
      dob: json['dob'],
      fatherName: json['father_name'],
      fatherPhone: json['father_phone'],
      motherName: json['mother_name'],
      address: json['address'],
      pincode: json['pincode']?.toString(),
      loginId: json['login_id'],
    );
  }
}

class OrderStatusOption {
  final String value;
  final String label;
  const OrderStatusOption(this.value, this.label);
}

const kOrderStatuses = [
  OrderStatusOption('order_created', 'Order Created'),
  OrderStatusOption('re_order', 'Re-Order'),
  OrderStatusOption('work_in_process', 'Work In Process'),
  OrderStatusOption('completed', 'Completed'),
  OrderStatusOption('cancelled', 'Cancelled'),
];

const kOrderFilterStatuses = [
  OrderStatusOption('', 'Filter By Status'),
  OrderStatusOption('order_created', 'Order Created'),
  OrderStatusOption('re_order', 'Re-Order'),
  OrderStatusOption('work_in_process', 'Work In Process'),
  OrderStatusOption('completed', 'Completed'),
  OrderStatusOption('cancelled', 'Cancelled'),
];

class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double completionRate;

  const OrderStatistics({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.completionRate = 0,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) => OrderStatistics(
        totalOrders: json['total_orders'] ?? 0,
        pendingOrders: json['pending_orders'] ?? 0,
        completedOrders: json['completed_orders'] ?? 0,
        cancelledOrders: json['cancelled_orders'] ?? 0,
        completionRate: (json['completion_rate'] ?? 0).toDouble(),
      );
}
