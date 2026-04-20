import 'package:idmitra/models/students/StudentsListModel.dart';

class AdminStudentsState {
  final bool loading;
  final bool isPaginationLoading;
  final List<StudentDetailsData> studentsList;
  final int page;
  final bool hasMore;
  final String? error;

  AdminStudentsState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.studentsList = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
  });

  AdminStudentsState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<StudentDetailsData>? studentsList,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return AdminStudentsState(
      loading: loading ?? this.loading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      studentsList: studentsList ?? this.studentsList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}
