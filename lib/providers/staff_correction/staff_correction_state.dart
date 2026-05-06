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
  final Set<int> selectedIds;
  final bool sendOrderLoading;
  final bool sendOrderSuccess;
  final String? sendOrderError;

  const StaffCorrectionState({
    this.loading = false,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,
    this.selectedIds = const {},
    this.sendOrderLoading = false,
    this.sendOrderSuccess = false,
    this.sendOrderError,
  });

  StaffCorrectionState copyWith({
    bool? loading,
    List<StaffCorrectionItem>? items,
    int? page,
    bool? hasMore,
    int? total,
    String? error,
    bool? clearError,
    Set<int>? selectedIds,
    bool? sendOrderLoading,
    bool? sendOrderSuccess,
    String? sendOrderError,
    bool? clearSendOrderError,
  }) {
    return StaffCorrectionState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      error: clearError == true ? null : (error ?? this.error),
      selectedIds: selectedIds ?? this.selectedIds,
      sendOrderLoading: sendOrderLoading ?? this.sendOrderLoading,
      sendOrderSuccess: sendOrderSuccess ?? this.sendOrderSuccess,
      sendOrderError: clearSendOrderError == true ? null : (sendOrderError ?? this.sendOrderError),
    );
  }
}
