import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';

class AddStudentState {
  final bool loading;
  final bool success;
  final String? error;
  final String? message;
  const AddStudentState({
    this.loading = false,
    this.success = false,
    this.error,
    this.message,
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
        if (v != null) request.fields[k] = v.toString();
      });

      final fileMap = {
        'student_photo': 'student_photo',
        'student_signature': 'student_signature',
        'father_photo': 'father_photo',
        'father_signature': 'father_signature',
        'mother_photo': 'mother_photo',
        'mother_signature': 'mother_signature',
      };
      for (final entry in fileMap.entries) {
        final file = files[entry.key];
        if (file != null) {
          print('Uploading ${entry.key} → ${entry.value}: ${file.path}');
          request.files.add(
            await http.MultipartFile.fromPath(entry.value, file.path),
          );
        } else {}
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? {};
        print('profile_photo_url: ${data['profile_photo_url']}');
        print('signature_url: ${data['signature_url']}');
        emit(
          AddStudentState(
            success: true,
            message: json['message'] ?? 'Student added successfully',
          ),
        );
      } else {
        final responseBody = response.body;
        print('Error response: $responseBody');
        Map<String, dynamic> json = {};
        try {
          json = jsonDecode(responseBody);
        } catch (_) {}
        String errorMsg = json['message'] ?? 'Failed: ${response.statusCode}';
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final errList = errors.values
              .expand((v) => v is List ? v : [v])
              .take(3)
              .join('\n');
          errorMsg = errList;
        }
        emit(AddStudentState(error: errorMsg));
      }
    } catch (e) {
      emit(AddStudentState(error: e.toString()));
    }
  }

  Map<String, dynamic> _buildBody(
    String schoolId,
    Map<String, dynamic> fields,
  ) {
    final gender = fields['gender']?.toString().toLowerCase();
    final cleanGender = (gender == null || gender == '-select gender-')
        ? null
        : gender;

    String? dob;
    final dobRaw = fields['date_of_birth']?.toString();
    if (dobRaw != null && dobRaw.isNotEmpty) {
      // support . / - separators
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

    return {
      'school_id': schoolId,
      'student_name': fields['student_name'],
      'name': fields['student_name'],
      'dob': dob,
      'gender': cleanGender,
      'blood_group': fields['blood_group'],
      'student_email': fields['student_email'],
      'email': fields['student_email'],
      'student_phone': fields['student_phone'],
      'phone': fields['student_phone'],
      'whatsapp_phone': fields['student_whatsapp'],
      'land_line_no': fields['landline_number'],
      'aadhar_no': fields['aadhar_card_number'],
      'uid_no': fields['uid_number'],
      'nic_id': fields['nic_id'],
      'caste': fields['caste'],
      'religion': fields['religion'],
      'is_rte_student': fields['is_rte_student'],
      'address': fields['address'],
      'pincode': fields['pincode'],
      'session': fields['session']?.toString(),
      'class': fields['class']?.toString(),
      'school_session_id': fields['session']?.toString(),
      'school_class_id': fields['class']?.toString(),
      'school_class_section_id': fields['class_section']?.toString(),
      'school_house_id': fields['house']?.toString(),
      'reg_no': fields['registration_number'],
      'roll_no': fields['roll_number'],
      'admission_no': fields['admission_number'],
      'sr_no': fields['sr_number'],
      'rfid_no': fields['rfid_number'],
      'pen_no': fields['pen_number'],
      'transport_mode': fields['transport_mode'],
      'father_name': fields['father_name'],
      'father_email': fields['father_email'],
      'father_phone': fields['father_phone'],
      'father_wphone': fields['father_whatsapp'],
      'mother_name': fields['mother_name'],
      'mother_email': fields['mother_email'],
      'mother_phone': fields['mother_phone'],
      'mother_wphone': fields['mother_whatsapp'],
      'password': fields['password'],
      'password_confirmation': fields['password'],
    };
  }
}
 