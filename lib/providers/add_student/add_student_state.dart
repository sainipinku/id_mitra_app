part of 'add_student_cubit.dart';

class AddStudentState {
  final bool loading;
  final bool success;
  final String? error;

  AddStudentState({
    this.loading = false,
    this.success = false,
    this.error,
  });

  AddStudentState copyWith({
    bool? loading,
    bool? success,
    String? error,
  }) {
    return AddStudentState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}
