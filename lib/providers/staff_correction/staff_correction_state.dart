import 'package:idmitra/models/staff/StaffListModel.dart';

class StaffCorrectionItem {
  final int id;
  final String? uuid;
  final String? status;
  final String? remark;
  final StaffListModel? staff;

  const StaffCorrectionItem({
    required this.id,
    this.uuid,
    this.status,
    this.remark,
    this.staff,
  });

  factory StaffCorrectionItem.fromJson(Map<String, dynamic> json) {
    final staffJson = json['staff'] as Map<String, dynamic>?;
    return StaffCorrectionItem(
      id: json['id'] ?? 0,
      uuid: json['uuid'],
      status: json['status'],
      remark: json['remark'],
      staff: staffJson != null ? StaffListModel.fromJson(staffJson) : null,
    );
  }
}

class StaffCorrectionState {
  final bool loading;
  final List<StaffCorrectionItem> items;
  final int page;
  final bool hasMore;
  final int total;
  final String? error;

  const StaffCorrectionState({
    this.loading = false,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,
  });

  StaffCorrectionState copyWith({
    bool? loading,
    List<StaffCorrectionItem>? items,
    int? page,
    bool? hasMore,
    int? total,
    String? error,
    bool? clearError,
  }) {
    return StaffCorrectionState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      error: clearError == true ? null : (error ?? this.error),
    );
  }
}
