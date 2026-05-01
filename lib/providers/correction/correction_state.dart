import 'package:idmitra/models/correction/CorrectionListModel.dart';

class CorrectionState {
  final bool loading;
  final List<CorrectionItem> items;
  final int page;
  final bool hasMore;
  final String? error;
  final Set<int> selectedIds;

  const CorrectionState({
    this.loading = false,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.selectedIds = const {},
  });

  CorrectionState copyWith({
    bool? loading,
    List<CorrectionItem>? items,
    int? page,
    bool? hasMore,
    String? error,
    bool? clearError,
    Set<int>? selectedIds,
  }) {
    return CorrectionState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: clearError == true ? null : (error ?? this.error),
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
