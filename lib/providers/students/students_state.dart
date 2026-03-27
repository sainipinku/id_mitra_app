import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';

class StudentsState {
  final bool loading;
  final bool isPaginationLoading;
  final List<StudentDetailsData> studentsList; // 👈 LIST
  final int page;
  final bool hasMore;
  final String? error;

  StudentsState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.studentsList = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
  });

  StudentsState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<StudentDetailsData>? studentsList,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return StudentsState(
      loading: loading ?? this.loading,
      isPaginationLoading:
      isPaginationLoading ?? this.isPaginationLoading,
      studentsList: studentsList ?? this.studentsList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}