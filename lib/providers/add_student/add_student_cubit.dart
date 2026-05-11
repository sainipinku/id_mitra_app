
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

      print("ADD STUDENT URL => $url");
      print("FULL BODY => $body");

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      body.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          request.fields[key] = value.toString();
        }
      });


      for (final key in [
        'student_photo',
        'student_signature',
        'father_photo',
        'father_signature',
        'mother_photo',
        'mother_signature',
      ]) {
        final file = files[key];

        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              key,
              file.path,
            ),
          );
        }
      }

      final streamed = await request.send();

      final response = await http.Response.fromStream(streamed);

      print("ADD RESPONSE CODE => ${response.statusCode}");
      print("ADD RESPONSE BODY => ${response.body}");


      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final json = jsonDecode(response.body);

        StudentDetailsData? student;

        try {
          final data = json['data'];

          if (data is Map<String, dynamic>) {
            student = StudentDetailsData.fromJson(data);
          }
        } catch (e) {
          debugPrint("PARSE ERROR => $e");
        }

        emit(
          AddStudentState(
            success: true,
            message:
            json['message'] ??
                'Student added successfully',
            newStudent: student,
          ),
        );
      }


      else {
        Map<String, dynamic> json = {};

        try {
          json = jsonDecode(response.body);
        } catch (_) {}

        String errorMsg =
            json['message'] ??
                'Failed: ${response.statusCode}';

        final errors =
        json['errors'] as Map<String, dynamic>?;

        if (errors != null && errors.isNotEmpty) {
          errorMsg = errors.values
              .expand((e) => e is List ? e : [e])
              .join('\n');
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

      final url =
          '${Config.baseUrl}${Routes.updateStudent(schoolId, studentUuid)}';

      final body = _buildBody(schoolId, fields);

      debugPrint("UPDATE BODY => $body");

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['_method'] = 'PUT';

      body.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          request.fields[key] = value.toString();
        }
      });

      for (final key in [
        'student_photo',
        'student_signature',
        'father_photo',
        'father_signature',
        'mother_photo',
        'mother_signature',
      ]) {
        final file = files[key];

        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              key,
              file.path,
            ),
          );
        }
      }

      final streamed = await request.send();

      final response = await http.Response.fromStream(streamed);

      debugPrint("UPDATE RESPONSE => ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final json = jsonDecode(response.body);

        StudentDetailsData? student;

        try {
          final data = json['data'];

          if (data is Map<String, dynamic>) {
            student = StudentDetailsData.fromJson(data);
          }
        } catch (e) {
          debugPrint("UPDATE PARSE ERROR => $e");
        }

        emit(
          AddStudentState(
            success: true,
            message:
            json['message'] ??
                'Student updated successfully',
            newStudent: student,
          ),
        );
      } else {
        Map<String, dynamic> json = {};

        try {
          json = jsonDecode(response.body);
        } catch (_) {}

        String errorMsg =
            json['message'] ??
                'Failed: ${response.statusCode}';

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
    String? value(List<String> keys) {
      for (final key in keys) {
        final v = fields[key];

        if (v != null &&
            v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }

      return null;
    }


    String? dob;

    final dobRaw =
    value(['date_of_birth', 'dob']);

    if (dobRaw != null && dobRaw.isNotEmpty) {
      final parts = dobRaw.split('.');

      if (parts.length == 3) {
        dob =
        '${parts[2]}-${parts[1]}-${parts[0]}';
      } else {
        dob = dobRaw;
      }
    }


    final session =
    value(['session', 'school_session_id']);

    final classId =
    value(['class', 'school_class_id']);

    final sectionId = value([
      'class_section',
      'school_class_section_id',
    ]);

    final houseId =
    value(['house', 'school_house_id']);

    debugPrint("FIELDS => $fields");

    debugPrint("FINAL SESSION => $session");
    debugPrint("FINAL CLASS => $classId");
    debugPrint("FINAL SECTION => $sectionId");

    return {
      "school_id": schoolId,


      "student_name": value(['student_name']),
      "name": value(['student_name']),

      "session": session,
      "school_session_id": session,

      "class": classId,
      "school_class_id": classId,

      "class_section": sectionId,
      "school_class_section_id": sectionId,

      "house": houseId,
      "school_house_id": houseId,


      "dob": dob,
      "date_of_birth": dob,

      "gender": value(['gender']),
      "blood_group": value(['blood_group']),

      "email": value(['student_email']),
      "student_email": value(['student_email']),

      "phone": value(['student_phone']),
      "student_phone": value(['student_phone']),

      "whatsapp_phone": value([
        'student_whatsapp_number',
        'student_whatsapp',
      ]),

      "land_line_no": value([
        'landline_contact_number',
        'landline_number',
      ]),

      "aadhar_no": value([
        'aadhar_card_number',
      ]),

      "uid_no": value([
        'uid_number',
      ]),

      "student_nic_id": value([
        'student_nic_id',
        'nic_id',
      ]),

      "caste": value(['caste']),
      "religion": value(['religion']),
      "is_rte_student": value(['is_rte_student']),

      "address": value(['address']),
      "pincode": value(['pincode']),


      "reg_no": value([
        'registration_number',
      ]),

      "roll_no": value([
        'roll_number',
      ]),

      "admission_no": value([
        'admission_number',
      ]),

      "sr_no": value([
        'sr_number',
      ]),

      "rfid_no": value([
        'rfid_number',
      ]),

      "pan_no": value([
        'pan_number',
        'pen_number',
      ]),

      "transport_mode": value([
        'transport_mode',
      ]),


      "father_name": value([
        'father_name',
      ]),

      "father_email": value([
        'father_email',
      ]),

      "father_phone": value([
        'father_phone',
      ]),

      "father_wphone": value([
        'father_whatsapp',
        'father_whatsapp_number',
      ]),


      "mother_name": value([
        'mother_name',
      ]),

      "mother_email": value([
        'mother_email',
      ]),

      "mother_phone": value([
        'mother_phone',
      ]),

      "mother_wphone": value([
        'mother_whatsapp',
        'mother_whatsapp_number',
      ]),


      "password":
      value(['password']) ?? 'Student@123',

      "password_confirmation":
      value(['password_confirmation']) ??
          value(['password']) ??
          'Student@123',
    };
  }
}