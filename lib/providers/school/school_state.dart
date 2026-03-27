import 'package:idmitra/models/schools/SchoolListModel.dart';

class SchoolState {
  final bool loading;
  final bool isPaginationLoading;
  final List<SchoolDetailsModel> students; // 👈 LIST
  final int page;
  final bool hasMore;
  final String? error;

  SchoolState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.students = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
  });

  SchoolState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<SchoolDetailsModel>? students,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return SchoolState(
      loading: loading ?? this.loading,
      isPaginationLoading:
      isPaginationLoading ?? this.isPaginationLoading,
      students: students ?? this.students,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}