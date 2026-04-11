part of 'student_form_cubit.dart';

class StudentFormState {
  final bool loading;
  final bool saving;
  final List<StudentFormField> fields;
  final List<StudentFormField> availableFields;
  final String schoolName;
  final String? error;
  final String? successMessage;

  StudentFormState({
    this.loading = false,
    this.saving = false,
    this.fields = const [],
    this.availableFields = const [],
    this.schoolName = '',
    this.error,
    this.successMessage,
  });

  StudentFormState copyWith({
    bool? loading,
    bool? saving,
    List<StudentFormField>? fields,
    List<StudentFormField>? availableFields,
    String? schoolName,
    String? error,
    String? successMessage,
  }) {
    return StudentFormState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      fields: fields ?? this.fields,
      availableFields: availableFields ?? this.availableFields,
      schoolName: schoolName ?? this.schoolName,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
