import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';

part 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  StudentFormCubit() : super(StudentFormState());

  String _sig = '';
  String _schoolId = '';

  void clearMessages() {
    emit(StudentFormState(
      loading: state.loading,
      saving: state.saving,
      fields: state.fields,
      availableFields: state.availableFields,
      schoolName: state.schoolName,
      error: null,
      successMessage: null,
    ));
  }

  /// Fetch fields from API — both current fields and available pool
  Future<void> loadFromSchoolId({
    required String schoolId,
    required String schoolName,
  }) async {
    _schoolId = schoolId;
    emit(state.copyWith(loading: true, error: null, successMessage: null));

    final token = await UserSecureStorage.fetchToken();
    final response = await http.get(
      Uri.parse('${Config.baseUrl}auth/school/$schoolId/form-fields'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('Form fields API: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? {};
      final List rawFields = data['student_form_fields'] ?? [];
      final fields = rawFields
          .map((e) => StudentFormField.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      emit(state.copyWith(
        loading: false,
        fields: fields,
        availableFields: fields,
        schoolName: schoolName,
      ));
    } else {
      emit(state.copyWith(loading: false, error: 'Failed to load form fields'));
    }
  }

  void loadFromModel({
    required List<StudentFormField> fields,
    required String schoolName,
    required String schoolId,
  }) {
    emit(state.copyWith(
      fields: fields,
      schoolName: schoolName,
      error: null,
      successMessage: null,
    ));
    _fetchSig(schoolId);
  }

  void loadFromModelWithSig({
    required List<StudentFormField> fields,
    required String schoolName,
    required String sig,
    String schoolId = '',
  }) {
    _sig = sig;
    _schoolId = schoolId;
    emit(state.copyWith(
      fields: fields,
      availableFields: fields,
      schoolName: schoolName,
      error: null,
      successMessage: null,
    ));
  }

  Future<void> _fetchSig(String schoolId) async {
    final token = await UserSecureStorage.fetchToken();
    final response = await http.get(
      Uri.parse('${Config.baseUrl}auth/school/student-form-sig'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _sig = json['sig'] ?? json['data']?['sig'] ?? '';
    }
    print('Sig result: $_sig (status: ${response.statusCode})');
  }

  /// PUT: save configuration
  Future<void> updateStudentFormFields(List<StudentFormField> updatedFields) async {
    emit(state.copyWith(saving: true, error: null, successMessage: null));

    final token = await UserSecureStorage.fetchToken();
    final url = '${Config.baseUrl}auth/school/$_schoolId/form-fields/student';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'fields': updatedFields.map((f) => {
          'name': f.name,
          'label': f.label,
          'group': f.group,
          'group_label': f.groupLabel,
          'type': f.type,
          'required': f.required,
          'order': f.order,
        }).toList(),
      }),
    );

    print('Update status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      emit(state.copyWith(
        saving: false,
        successMessage: json['message'] ?? 'Form fields updated successfully',
        fields: updatedFields,
      ));
    } else {
      emit(state.copyWith(saving: false, error: 'Update failed: ${response.statusCode}'));
    }
  }
}
