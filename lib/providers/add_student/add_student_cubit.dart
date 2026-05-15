import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
    List<String> formFieldNames = const [],
  }) async {
    emit(const AddStudentState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}auth/school/$schoolId/students';

      final body = _buildBody(schoolId, fields);
      // debugPrint('=== ADD STUDENT REQUEST BODY ===');
      // body.forEach((k, v) => debugPrint('  $k: $v'));
      // debugPrint('================================');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      body.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          request.fields[k] = v.toString();
        }
      });

      for (final key in [
        'student_photo',
        'student_signature',
        'father_photo',
        'father_signature',
        'mother_photo',
        'mother_signature'
      ]) {
        final file = files[key];
        if (file != null) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      //
      // debugPrint('=== ADD STUDENT RESPONSE (${response.statusCode}) ===');
      // debugPrint(response.body);
      // debugPrint('====================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? {};
        StudentDetailsData? newStudent;
        try {
          if (data is Map<String, dynamic>) {
            // Patch school_class_section_id from request if API response omits it
            final sectionId = fields['class_section'];
            if (sectionId != null && data['school_class_section_id'] == null) {
              data['school_class_section_id'] = sectionId is int
                  ? sectionId
                  : int.tryParse(sectionId.toString());
            }
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
        try {
          json = jsonDecode(response.body);
        } catch (_) {}
        String errorMsg = json['message'] ?? 'Failed: ${response.statusCode}';
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final relevantErrors = formFieldNames.isEmpty
              ? errors
              : Map.fromEntries(
              errors.entries.where((e) => formFieldNames.contains(e.key)));
          if (relevantErrors.isNotEmpty) {
            errorMsg = relevantErrors.values
                .expand((v) => v is List ? v : [v])
                .take(3)
                .join('\n');
          } else {
            errorMsg = 'Failed to add student. Please try again.';
          }
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
    List<String> formFieldNames = const [],
  }) async {
    emit(const AddStudentState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.updateStudent(schoolId, studentUuid)}';

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

      for (final key in [
        'student_photo',
        'student_signature',
        'father_photo',
        'father_signature',
        'mother_photo',
        'mother_signature'
      ]) {
        final file = files[key];
        if (file != null) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().startsWith('<')) {
          emit(const AddStudentState(
              success: true, message: 'Student updated successfully'));
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
        try {
          json = jsonDecode(response.body);
        } catch (_) {}
        String errorMsg = json['message'] ?? 'Failed: ${response.statusCode}';
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final relevantErrors = formFieldNames.isEmpty
              ? errors
              : Map.fromEntries(
              errors.entries.where((e) => formFieldNames.contains(e.key)));
          if (relevantErrors.isNotEmpty) {
            errorMsg = relevantErrors.values
                .expand((v) => v is List ? v : [v])
                .take(3)
                .join('\n');
          } else {
            errorMsg = 'Failed to update student. Please try again.';
          }
        }
        emit(AddStudentState(error: errorMsg));
      }
    } catch (e) {
      emit(AddStudentState(error: e.toString()));
    }
  }

  Map<String, dynamic> _buildBody(String schoolId, Map<String, dynamic> fields) {
    final gender = fields['gender']?.toString().toLowerCase();
    final cleanGender =
    (gender == null || gender == '-select gender-') ? null : gender;

    String? dob;
    final dobRaw = fields['date_of_birth']?.toString();
    if (dobRaw != null && dobRaw.isNotEmpty) {
      final parts = dobRaw.split(RegExp(r'[./\-]'));
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        dob = '$year-$month-$day';
      } else {
        dob = dobRaw;
      }
    }

    String? f(List<String> keys) {
      for (final k in keys) {
        final v = fields[k]?.toString();
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    final password = f(['password']);
    final passwordConfirmation = f(['password_confirmation']);

    final String? finalPassword;
    final String? finalPasswordConfirmation;

    if (password != null && password.isNotEmpty) {
      finalPassword = password;
      finalPasswordConfirmation = passwordConfirmation ?? password;
    } else {
      finalPassword = 'Student@123';
      finalPasswordConfirmation = 'Student@123';
    }

    return {
      'school_id': schoolId,
      'student_name': f(['student_name']),
      'name': f(['student_name']),
      'dob': dob,
      'date_of_birth': dob,
      'gender': cleanGender,
      'blood_group': f(['blood_group']),
      'email': f(['student_email']),
      'student_email': f(['student_email']),
      'phone': f(['student_phone']),
      'student_phone': f(['student_phone']),
      'whatsapp_phone': f(['student_whatsapp_number', 'student_whatsapp', 'whatsapp_number']),
      'student_whatsapp_number': f(['student_whatsapp_number', 'student_whatsapp']),
      'land_line_no': f(['landline_contact_number', 'landline_number', 'land_line_no']),
      'landline_contact_number': f(['landline_contact_number', 'landline_number']),
      'aadhar_no': f(['aadhar_card_number', 'aadhar_no']),
      'aadhar_card_number': f(['aadhar_card_number', 'aadhar_no']),
      'uid_no': f(['uid_number', 'uid_no']),
      'uid_number': f(['uid_number', 'uid_no']),
      'student_nic_id': f(['student_nic_id', 'nic_id']),
      'pan_no': f(['pen_number', 'pan_number', 'pan_no']),
      'pen_number': f(['pen_number', 'pan_number', 'pan_no']),
      'caste': f(['caste']),
      'religion': f(['religion']),
      'is_rte_student': f(['is_rte_student']),
      'address': f(['address']),
      'pincode': f(['pincode']),
      'school_session_id': fields['session']?.toString(),
      'session': fields['session']?.toString(),
      'school_class_id': fields['class']?.toString(),
      'class': fields['class']?.toString(),
      'school_class_section_id': fields['class_section']?.toString(),
      'school_house_id': fields['house']?.toString(),
      'house': fields['house']?.toString(),

      'reg_no': f(['registration_number', 'reg_no']),
      'registration_number': f(['registration_number', 'reg_no']),
      'roll_no': f(['roll_number', 'roll_no']),
      'roll_number': f(['roll_number', 'roll_no']),
      'admission_no': f(['admission_number', 'admission_no']),
      'admission_number': f(['admission_number', 'admission_no']),
      'sr_no': f(['sr_number', 'sr_no']),
      'sr_number': f(['sr_number', 'sr_no']),
      'rfid_no': f(['rfid_number', 'rfid_no']),
      'rfid_number': f(['rfid_number', 'rfid_no']),

      'transport_mode': f(['transport_mode']),

      'father_name': f(['father_name']),
      'father_email': f(['father_email']),
      'father_phone': f(['father_phone']),
      'father_wphone': f(['father_whatsapp_number', 'father_whatsapp']),

      'mother_name': f(['mother_name']),
      'mother_email': f(['mother_email']),
      'mother_phone': f(['mother_phone']),
      'mother_wphone': f(['mother_whatsapp_number', 'mother_whatsapp']),

      'password': finalPassword,
      'password_confirmation': finalPasswordConfirmation,
    };
  }
}