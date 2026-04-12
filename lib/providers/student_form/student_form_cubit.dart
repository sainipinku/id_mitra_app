import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';

part 'student_form_state.dart';

/// Master list of all possible student form fields.
/// Used as fallback when the API does not return available_student_form_fields.
const List<Map<String, dynamic>> _kAllAvailableFields = [
  {'name': 'date_of_birth',       'label': 'Date of Birth',        'type': 'date',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 1},
  {'name': 'blood_group',         'label': 'Blood Group',          'type': 'select',   'group': 'student', 'group_label': 'Student', 'required': false, 'order': 2},
  {'name': 'student_phone',       'label': 'Student Phone',        'type': 'phone',    'group': 'student', 'group_label': 'Student', 'required': false, 'order': 3},
  {'name': 'student_whatsapp',    'label': 'Student WhatsApp',     'type': 'phone',    'group': 'student', 'group_label': 'Student', 'required': false, 'order': 4},
  {'name': 'landline_number',     'label': 'Landline Number',      'type': 'phone',    'group': 'student', 'group_label': 'Student', 'required': false, 'order': 5},
  {'name': 'student_email',       'label': 'Student Email',        'type': 'email',    'group': 'student', 'group_label': 'Student', 'required': false, 'order': 6},
  {'name': 'aadhar_card_number',  'label': 'Aadhar Card Number',   'type': 'digits',   'group': 'student', 'group_label': 'Student', 'required': false, 'order': 7},
  {'name': 'uid_number',          'label': 'UID Number',           'type': 'text',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 8},
  {'name': 'student_photo',       'label': 'Student Photo',        'type': 'file',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 9},
  {'name': 'student_signature',   'label': 'Student Signature',    'type': 'file',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 10},
  {'name': 'nic_id',              'label': 'NIC ID',               'type': 'text',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 11},
  {'name': 'caste',               'label': 'Caste',                'type': 'text',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 12},
  {'name': 'is_rte_student',      'label': 'Is RTE Student',       'type': 'select',   'group': 'student', 'group_label': 'Student', 'required': false, 'order': 13},
  {'name': 'religion',            'label': 'Religion',             'type': 'text',     'group': 'student', 'group_label': 'Student', 'required': false, 'order': 14},
  {'name': 'father_name',         'label': 'Father Name',          'type': 'text',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 15},
  {'name': 'father_email',        'label': 'Father Email',         'type': 'email',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 16},
  {'name': 'father_phone',        'label': 'Father Phone',         'type': 'phone',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 17},
  {'name': 'father_whatsapp',     'label': 'Father WhatsApp',      'type': 'phone',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 18},
  {'name': 'father_photo',        'label': 'Father Photo',         'type': 'file',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 19},
  {'name': 'father_signature',    'label': 'Father Signature',     'type': 'file',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 20},
  {'name': 'mother_name',         'label': 'Mother Name',          'type': 'text',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 21},
  {'name': 'mother_email',        'label': 'Mother Email',         'type': 'email',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 22},
  {'name': 'mother_phone',        'label': 'Mother Phone',         'type': 'phone',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 23},
  {'name': 'mother_whatsapp',     'label': 'Mother WhatsApp',      'type': 'phone',    'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 24},
  {'name': 'mother_photo',        'label': 'Mother Photo',         'type': 'file',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 25},
  {'name': 'mother_signature',    'label': 'Mother Signature',     'type': 'file',     'group': 'parent',  'group_label': 'Parent',  'required': false, 'order': 26},
  {'name': 'address',             'label': 'Address',              'type': 'textarea', 'group': 'address', 'group_label': 'Address', 'required': false, 'order': 27},
  {'name': 'pincode',             'label': 'Pincode',              'type': 'digits',   'group': 'address', 'group_label': 'Address', 'required': false, 'order': 28},
  {'name': 'session',             'label': 'Session',              'type': 'select',   'group': 'school',  'group_label': 'School',  'required': false, 'order': 29},
  {'name': 'class',               'label': 'Class',                'type': 'select',   'group': 'school',  'group_label': 'School',  'required': false, 'order': 30},
  {'name': 'class_section',       'label': 'Class Section',        'type': 'select',   'group': 'school',  'group_label': 'School',  'required': false, 'order': 31},
  {'name': 'house',               'label': 'House',                'type': 'select',   'group': 'school',  'group_label': 'School',  'required': false, 'order': 32},
  {'name': 'registration_number', 'label': 'Registration Number',  'type': 'text',     'group': 'school',  'group_label': 'School',  'required': false, 'order': 33},
  {'name': 'roll_number',         'label': 'Roll Number',          'type': 'text',     'group': 'school',  'group_label': 'School',  'required': false, 'order': 34},
  {'name': 'pen_number',          'label': 'PEN Number',           'type': 'text',     'group': 'school',  'group_label': 'School',  'required': false, 'order': 35},
  {'name': 'sr_number',           'label': 'Sr. Number',           'type': 'text',     'group': 'school',  'group_label': 'School',  'required': false, 'order': 36},
  {'name': 'rfid_number',         'label': 'RFID Number',          'type': 'text',     'group': 'school',  'group_label': 'School',  'required': false, 'order': 37},
  {'name': 'password',            'label': 'Password',             'type': 'password', 'group': 'account', 'group_label': 'Account', 'required': false, 'order': 38},
  {'name': 'confirm_password',    'label': 'Confirm Password',     'type': 'password', 'group': 'account', 'group_label': 'Account', 'required': false, 'order': 39},
];

List<StudentFormField> get _masterAvailableFields => _kAllAvailableFields
    .map((e) => StudentFormField.fromJson(Map<String, dynamic>.from(e)))
    .toList();

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

      // Use API available fields if provided, otherwise fall back to master list
      final List rawAvailable = data['available_student_form_fields'] ?? [];
      final availableFields = rawAvailable.isNotEmpty
          ? rawAvailable
              .map((e) => StudentFormField.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : _masterAvailableFields;

      emit(state.copyWith(
        loading: false,
        fields: fields,
        availableFields: availableFields,
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
    _schoolId = schoolId; // ← ensure schoolId is always set
    emit(state.copyWith(
      fields: fields,
      availableFields: _masterAvailableFields,
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
      availableFields: _masterAvailableFields,
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

  Future<void> updateStudentFormFields(List<StudentFormField> updatedFields) async {
    emit(state.copyWith(saving: true, error: null, successMessage: null));

    // fallback: read schoolId from SharedPreferences if not set in memory
    if (_schoolId.isEmpty) {
      final school = await UserLocal.getSchool();
      _schoolId = school['schoolId'] ?? '';
    }

    if (_schoolId.isEmpty) {
      emit(state.copyWith(saving: false, error: 'School ID not found. Please reopen this screen.'));
      return;
    }

    final token = await UserSecureStorage.fetchToken();
    final url = '${Config.baseUrl}auth/school/$_schoolId/form-fields/student';
    print('Update URL: $url');

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
