import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/staff/StaffDetailModel.dart';

class AddStaffState {
  final bool loading;
  final bool success;
  final String? error;
  final String? message;
  final StaffDetailModel? updatedStaff;

  const AddStaffState({
    this.loading = false,
    this.success = false,
    this.error,
    this.message,
    this.updatedStaff,
  });
}

class AddStaffCubit extends Cubit<AddStaffState> {
  AddStaffCubit() : super(const AddStaffState());

  Future<void> submit({
    required String schoolId,
    required Map<String, dynamic> fields,
    required List<Map<String, String>> emergencyContacts,
  }) async {
    emit(const AddStaffState(loading: true));
    try {

      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';


      final url = Config.url(Routes.addStaff(schoolId, isPartner: isPartner));

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      print('=== REQUEST HEADERS: ${request.headers}');
      print('=== REQUEST URL: ${request.url}');

      final body = _buildBody(schoolId, fields, isAdd: true);
      body.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          request.fields[k] = v.toString();
        }
      });

      for (int i = 0; i < emergencyContacts.length; i++) {
        emergencyContacts[i].forEach((k, v) {
          if (v.isNotEmpty) request.fields['emergency_contacts[$i][$k]'] = v;
        });
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('=== ADD STAFF RESPONSE STATUS: ${response.statusCode}');
      print('=== ADD STAFF RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        emit(AddStaffState(
          success: true,
          message: json['message'] ?? 'Staff added successfully',
        ));
      } else {
        final errorMsg = _parseError(response);
        emit(AddStaffState(error: errorMsg));
      }
    } catch (e) {
      emit(AddStaffState(error: 'Error: ${e.toString()}'));
    }
  }

  Future<void> update({
    required String schoolId,
    required String uuid,
    required Map<String, dynamic> fields,
    required List<Map<String, String>> emergencyContacts,
    String? roleId,
  }) async {
    emit(const AddStaffState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';
      final url = Config.url(Routes.updateStaff(schoolId, uuid, isPartner: isPartner));
      print('=== UPDATE STAFF URL: $url');
      final body = _buildBody(schoolId, fields);
      if (roleId != null && roleId.isNotEmpty) {
        final roleInt = int.tryParse(roleId);
        body['role'] = roleInt ?? roleId;
      }

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT';

      body.forEach((k, v) {
        if (v != null && v.toString().isNotEmpty) {
          request.fields[k] = v.toString();
        }
      });

      for (int i = 0; i < emergencyContacts.length; i++) {
        emergencyContacts[i].forEach((k, v) {
          if (v.isNotEmpty) request.fields['emergency_contacts[$i][$k]'] = v;
        });
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('UPDATE RESPONSE STATUS: ${response.statusCode}');
      print('UPDATE RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final staffData = json['data'] as Map<String, dynamic>?;
        emit(AddStaffState(
          success: true,
          message: json['message'] ?? 'Staff updated successfully',
          updatedStaff: staffData != null ? StaffDetailModel.fromJson(staffData) : null,
        ));
      } else {
        emit(AddStaffState(error: _parseError(response)));
      }
    } catch (e) {
      emit(AddStaffState(error: e.toString()));
    }
  }

  String _parseError(http.Response response) {
    Map<String, dynamic> json = {};
    try {
      json = jsonDecode(response.body);
    } catch (_) {
      return response.body.isNotEmpty
          ? response.body
          : 'Request failed with status ${response.statusCode}';
    }

    String msg = json['message'] ?? 'Request failed with status ${response.statusCode}';

    final errors = json['errors'] as Map<String, dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final errorMessages = errors.entries
          .expand((e) => e.value is List ? e.value as List : [e.value])
          .take(3)
          .join('\n');
      if (errorMessages.isNotEmpty) msg = errorMessages;
    }

    if (response.statusCode == 404) {
      msg = 'API endpoint not found. Please contact support.';
    } else if (response.statusCode == 403) {
      msg = 'You do not have permission to perform this action.';
    } else if (response.statusCode == 401) {
      msg = 'Session expired. Please login again.';
    } else if (response.statusCode == 422) {
      if (!msg.contains('required') && !msg.contains('invalid')) {
        msg = 'Validation failed: $msg';
      }
    } else if (response.statusCode >= 500) {
      msg = 'Server error. Please try again later.';
    }

    return msg;
  }

  Map<String, dynamic> _buildBody(String schoolId, Map<String, dynamic> fields, {bool isAdd = false}) {
    String? convertDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      final parts = raw.split(RegExp(r'[./\-]'));
      if (parts.length == 3) {
        if (parts[0].length == 4) return raw;
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
      return raw;
    }

    final body = <String, dynamic>{'school_id': schoolId};

    if (isAdd) {
      final pw = fields['password']?.toString().trim() ?? '';
      if (pw.isEmpty) {
        body['password'] = 'Staff@1234';
        body['password_confirmation'] = 'Staff@1234';
      }
    }

    fields.forEach((key, value) {
      if (value == null) return;
      final str = value.toString().trim();
      if (str.isEmpty) return;

      switch (key) {
        case 'date_of_birth':
        case 'dob':
          body['date_of_birth'] = convertDate(str);
          break;
        case 'date_of_joining':
          body['date_of_joining'] = convertDate(str);
          break;
        case 'gender':
          final g = str.toLowerCase();
          if (g != '-select gender-') body['gender'] = g;
          break;
        case 'blood_group':
          if (str != 'Select Blood Group') body['blood_group'] = str;
          break;
        case 'whatsapp':
          body['whatsapp_phone'] = str;
          break;
        case 'role':
        case 'role_id':
          if (int.tryParse(str) != null) {
            body['role'] = int.parse(str);
          }
          break;
        default:
          body[key] = str;
      }
    });

    return body;
  }
}