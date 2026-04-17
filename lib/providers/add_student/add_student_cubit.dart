import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';

class AddStudentState {
  final bool loading;
  final bool success;
  final String? error;
  final String? message;
  final StudentDetailsData? newStudent;
  const AddStudentState({
    this.loading = false,
    this.success = false,
    this.error,
    this.message,
    this.newStudent,
  });
}

class AddStudentCubit extends Cubit<AddStudentState> {
  AddStudentCubit() : super(const AddStudentState());

  Future<void> submit({
    required String schoolId,
    required Map<String, dynamic> fields,
    required Map<String, File?> files,
  }) async {
    emit(const AddStudentState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}auth/school/$schoolId/students';
      print('Add student URL: $url');

      final body = _buildBody(schoolId, fields);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      body.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          request.fields[k] = v.toString();
        }
      });
      print('Sending fields to API: ${request.fields}');

      for (final key in ['student_photo', 'student_signature', 'father_photo', 'father_signature', 'mother_photo', 'mother_signature']) {
        final file = files[key];
        if (file != null) {
          print('Uploading $key: ${file.path}');
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('status code-----${response.statusCode} and base url----$url');
      print('response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? {};
        StudentDetailsData? newStudent;
        try {
          if (data is Map<String, dynamic>) {
            newStudent = StudentDetailsData.fromJson(data);
          }
        } catch (_) {}
        emit(AddStudentState(
          success: true,
          message: json['message'] ?? 'Student added successfully',
          newStudent: newStudent,
        ));
      } else {
        Map<String, dynamic> json = {};
        try { json = jsonDecode(response.body); } catch (_) {}
        String errorMsg = json['message'] ?? 'Failed: ${response.statusCode}';
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          errorMsg = errors.values.expand((v) => v is List ? v : [v]).take(3).join('\n');
        }
        emit(AddStudentState(error: errorMsg));
      }
    } catch (e) {
      emit(AddStudentState(error: e.toString()));
    }
  }

  Future<void> updateStudent({
    required String studentUuid,
    required String schoolId,
    required Map<String, dynamic> fields,
    required Map<String, File?> files,
  }) async {
    emit(const AddStudentState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.updateStudent(schoolId, studentUuid)}';
      print('Update student URL: $url');

      final body = _buildBody(schoolId, fields);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT';

      body.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          request.fields[k] = v.toString();
        }
      });
      print('Update sending fields: ${request.fields}');

      for (final key in ['student_photo', 'student_signature', 'father_photo', 'father_signature', 'mother_photo', 'mother_signature']) {
        final file = files[key];
        if (file != null) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('Update student status: ${response.statusCode}');
      print('Update student response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().startsWith('<')) {
          emit(AddStudentState(success: true, message: 'Student updated successfully'));
          return;
        }
        final json = jsonDecode(response.body);
        StudentDetailsData? updatedStudent;
        try {
          final data = json['data'];
          if (data is Map<String, dynamic>) {
            updatedStudent = StudentDetailsData.fromJson(data);
          }
        } catch (_) {}
        emit(AddStudentState(
          success: true,
          message: json['message'] ?? 'Student updated successfully',
          newStudent: updatedStudent,
        ));
      } else {
        Map<String, dynamic> json = {};
        try { json = jsonDecode(response.body); } catch (_) {}
        String errorMsg = json['message'] ?? 'Failed: ${response.statusCode}';
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          errorMsg = errors.values.expand((v) => v is List ? v : [v]).take(3).join('\n');
        }
        emit(AddStudentState(error: errorMsg));
      }
    } catch (e) {
      emit(AddStudentState(error: e.toString()));
    }
  }

  Map<String, dynamic> _buildBody(String schoolId, Map<String, dynamic> fields) {
    print('Form fields received: $fields');

    final gender = fields['gender']?.toString().toLowerCase();
    final cleanGender = (gender == null || gender == '-select gender-') ? null : gender;

    String? dob;
    final dobRaw = fields['date_of_birth']?.toString();
    if (dobRaw != null && dobRaw.isNotEmpty) {
      final parts = dobRaw.split(RegExp(r'[./\-]'));
      if (parts.length == 3) {
        // dd.mm.yyyy → yyyy-mm-dd
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        dob = '$year-$month-$day';
      } else {
        dob = dobRaw;
      }
    }

    // Helper to get first non-empty value
    String? _f(List<String> keys) {
      for (final k in keys) {
        final v = fields[k]?.toString();
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    return {
      'school_id': schoolId,
      'student_name': _f(['student_name']),
      'name': _f(['student_name']),
      'dob': dob,
      'gender': cleanGender,
      'blood_group': _f(['blood_group']),
      'email': _f(['student_email']),
      'phone': _f(['student_phone']),
      'whatsapp_phone': _f(['student_whatsapp_number', 'student_whatsapp', 'whatsapp_number']),
      'land_line_no': _f(['landline_contact_number', 'landline_number', 'land_line_no']),
      'aadhar_no': _f(['aadhar_card_number', 'aadhar_no']),
      'uid_no': _f(['uid_number', 'uid_no']),
      'student_nic_id': _f(['student_nic_id', 'nic_id']),
      'caste': _f(['caste']),
      'religion': _f(['religion']),
      'is_rte_student': _f(['is_rte_student']),
      'address': _f(['address']),
      'pincode': _f(['pincode']),
      'school_session_id': fields['session']?.toString(),
      'school_class_id': fields['class']?.toString(),
      'session': fields['session']?.toString(),
      'class': fields['class']?.toString(),
      // Alternate keys - API may use different names
      'student_whatsapp_number': _f(['student_whatsapp_number', 'student_whatsapp']),
      'landline_contact_number': _f(['landline_contact_number', 'landline_number']),
      'uid_number': _f(['uid_number', 'uid_no']),
      'date_of_birth': dob,
      'student_email': _f(['student_email']),
      'school_class_section_id': fields['class_section']?.toString(),
      'school_house_id': fields['house']?.toString(),
      'reg_no': _f(['registration_number', 'reg_no']),
      'roll_no': _f(['roll_number', 'roll_no']),
      'admission_no': _f(['admission_number', 'admission_no']),
      'sr_no': _f(['sr_number', 'sr_no']),
      'rfid_no': _f(['rfid_number', 'rfid_no']),
      'transport_mode': _f(['transport_mode']),
      'father_name': _f(['father_name']),
      'father_email': _f(['father_email']),
      'father_phone': _f(['father_phone']),
      'father_wphone': _f(['father_whatsapp_number', 'father_whatsapp']),
      'mother_name': _f(['mother_name']),
      'mother_email': _f(['mother_email']),
      'mother_phone': _f(['mother_phone']),
      'mother_wphone': _f(['mother_whatsapp_number', 'mother_whatsapp']),
      'password': _f(['password']),
      'password_confirmation': _f(['password_confirmation', 'password']),
    };
  }
}
