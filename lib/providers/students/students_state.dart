import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';

class StudentsState {
  final bool loading;
  final bool isPaginationLoading;
  final List<StudentDetailsData> studentsList; // 👈 LIST
  final int page;
  final bool hasMore;
  final String? error;
  /// 🔥 Filters
  final String selectedClassId;
  final List<int> selectedSectionIds;
  final String selectedGender;
  StudentsState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.studentsList = const [],
    this.page = 1,
    this.hasMore = true,
    this.error,
    this.selectedClassId = "",
    this.selectedSectionIds = const [],
    this.selectedGender = "",
  });

  StudentsState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<StudentDetailsData>? studentsList,
    int? page,
    bool? hasMore,
    String? error,
    String? selectedClassId,
    List<int>? selectedSectionIds,
    String? selectedGender,
  }) {
    return StudentsState(
      loading: loading ?? this.loading,
      isPaginationLoading:
      isPaginationLoading ?? this.isPaginationLoading,
      studentsList: studentsList ?? this.studentsList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedSectionIds: selectedSectionIds ?? this.selectedSectionIds,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }
}