import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';

class StudentsState {
  final bool loading;
  final bool isPaginationLoading;
  final List<StudentDetailsData> studentsList;
  final int page;
  final bool hasMore;
  final String? error;

  // Extra (moved) students
  final bool extraLoading;
  final List<StudentDetailsData> extraStudentsList;

  StudentsState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.studentsList = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.extraLoading = false,
    this.extraStudentsList = const [],
  });

  StudentsState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<StudentDetailsData>? studentsList,
    int? page,
    bool? hasMore,
    String? error,
    bool? extraLoading,
    List<StudentDetailsData>? extraStudentsList,
  }) {
    return StudentsState(
      loading: loading ?? this.loading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      studentsList: studentsList ?? this.studentsList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      extraLoading: extraLoading ?? this.extraLoading,
      extraStudentsList: extraStudentsList ?? this.extraStudentsList,
    );
  }
}