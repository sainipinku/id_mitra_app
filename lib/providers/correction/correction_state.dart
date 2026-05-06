import 'package:idmitra/models/correction/CorrectionListModel.dart';

class DownloadColumn {
  final String key;
  final String label;
  const DownloadColumn({required this.key, required this.label});
}

class CorrectionState {
  final bool loading;
  final List<CorrectionItem> items;
  final int page;
  final bool hasMore;
  final String? error;
  final int studentsTotal;
  final Set<int> selectedIds;
  final bool sendOrderLoading;
  final bool sendOrderSuccess;
  final String? sendOrderError;
  final bool downloadLoading;
  final String? downloadUrl;
  final String? downloadError;
  final bool columnsLoading;
  final List<DownloadColumn> downloadColumns;
  final List<String> selectedClassIds;

  final bool studentsLoading;
  final List<CorrectionStudentItem> students;
  final int studentsPage;
  final bool studentsHasMore;
  final String? studentsError;
  final Set<int> selectedStudentIds;

  const CorrectionState({
    this.loading = false,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.studentsTotal = 0,

    this.selectedIds = const {},
    this.sendOrderLoading = false,
    this.sendOrderSuccess = false,
    this.sendOrderError,
    this.downloadLoading = false,
    this.downloadUrl,
    this.downloadError,
    this.columnsLoading = false,
    this.downloadColumns = const [],
    this.studentsLoading = false,
    this.students = const [],
    this.studentsPage = 1,
    this.studentsHasMore = true,
    this.studentsError,
    this.selectedStudentIds = const {},
    this.selectedClassIds = const [],

  });

  CorrectionState copyWith({
    bool? loading,
    List<CorrectionItem>? items,
    int? page,
    int? studentsTotal,

    bool? hasMore,
    String? error,
    bool? clearError,
    Set<int>? selectedIds,
    bool? sendOrderLoading,
    bool? sendOrderSuccess,
    String? sendOrderError,
    bool? clearSendOrderError,
    bool? downloadLoading,
    String? downloadUrl,
    String? downloadError,
    bool? clearDownloadError,
    bool? clearDownloadUrl,
    bool? columnsLoading,
    List<DownloadColumn>? downloadColumns,
    bool? studentsLoading,
    List<CorrectionStudentItem>? students,
    int? studentsPage,
    bool? studentsHasMore,
    String? studentsError,
    bool? clearStudentsError,
    Set<int>? selectedStudentIds,
    List<String>? selectedClassIds,

  }) {
    return CorrectionState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      page: page ?? this.page,
      studentsTotal: studentsTotal ?? this.studentsTotal,

      hasMore: hasMore ?? this.hasMore,
      error: clearError == true ? null : (error ?? this.error),
      selectedIds: selectedIds ?? this.selectedIds,
      sendOrderLoading: sendOrderLoading ?? this.sendOrderLoading,
      sendOrderSuccess: sendOrderSuccess ?? this.sendOrderSuccess,
      sendOrderError: clearSendOrderError == true ? null : (sendOrderError ?? this.sendOrderError),
      downloadLoading: downloadLoading ?? this.downloadLoading,
      downloadUrl: clearDownloadUrl == true ? null : (downloadUrl ?? this.downloadUrl),
      downloadError: clearDownloadError == true ? null : (downloadError ?? this.downloadError),
      columnsLoading: columnsLoading ?? this.columnsLoading,
      downloadColumns: downloadColumns ?? this.downloadColumns,
      studentsLoading: studentsLoading ?? this.studentsLoading,
      students: students ?? this.students,
      studentsPage: studentsPage ?? this.studentsPage,
      studentsHasMore: studentsHasMore ?? this.studentsHasMore,
      studentsError: clearStudentsError == true ? null : (studentsError ?? this.studentsError),
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
      selectedClassIds: selectedClassIds ?? this.selectedClassIds,

    );
  }
}
