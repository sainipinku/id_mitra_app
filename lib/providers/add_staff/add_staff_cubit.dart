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

      final body = _buildBody(schoolId, fields);
      print('SUBMIT BODY: $body');

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
      print('ADD STAFF RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        emit(AddStaffState(
          success: true,
          message: json['message'] ?? 'Staff added successfully',
        ));
      } else {
        emit(AddStaffState(error: _parseError(response)));
      }
    } catch (e) {
      print('ADD STAFF EXCEPTION: $e');
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
      if (token == null) {
        emit(const AddStaffState(error: 'Authentication token not found'));
        return;
      }

      final url = Config.url(Routes.updateStaff(schoolId, uuid));
      print('Update staff URL: $url');

      final body = <String, dynamic>{};
      _addIfNotEmpty(body, 'name', fields['name']);
      _addIfNotEmpty(body, 'email', fields['email']);
      _addIfNotEmpty(body, 'phone', fields['phone']);
      _addIfNotEmpty(body, 'designation', fields['designation']);
      _addIfNotEmpty(body, 'department', fields['department']);
      _addIfNotEmpty(body, 'login_id', fields['login_id']);
      _addIfNotEmpty(body, 'whatsapp_phone', fields['whatsapp'] ?? fields['whatsapp_phone']);
      _addIfNotEmpty(body, 'father_name', fields['father_name']);
      _addIfNotEmpty(body, 'mother_name', fields['mother_name']);
      _addIfNotEmpty(body, 'husband_name', fields['husband_name']);
      _addIfNotEmpty(body, 'dob', _convertDate(fields['date_of_birth']));
      _addIfNotEmpty(body, 'date_of_joining', _convertDate(fields['date_of_joining']));
      _addIfNotEmpty(body, 'address', fields['address']);
      _addIfNotEmpty(body, 'pincode', fields['pincode']);
      _addIfNotEmpty(body, 'employee_id', fields['employee_id']);
      _addIfNotEmpty(body, 'national_code', fields['national_code']);

      final roleRaw = roleId ?? fields['role'];

      if (roleRaw != null) {
        String roleStr = roleRaw.toString().trim();

        if (roleStr.startsWith('[') && roleStr.endsWith(']')) {
          roleStr = roleStr.replaceAll('[', '').replaceAll(']', '').trim();
        }

        final roleInt = int.tryParse(roleStr);
        if (roleInt != null) {
          body['role'] = roleInt;
          print('Role successfully set as integer: $roleInt');
        } else {
          print('Warning: Could not convert role to int → $roleRaw');
        }
      }


      final gender = fields['gender']?.toString().trim() ?? '';
      if (gender.isNotEmpty && gender.toLowerCase() != '-select gender-') {
        body['gender'] = gender.toLowerCase();
      }

      final bg = fields['blood_group']?.toString().trim() ?? '';
      if (bg.isNotEmpty && bg != 'Select Blood Group') {
        body['blood_group'] = bg;
      }

      final validContacts = emergencyContacts
          .where((e) =>
      (e['name'] ?? '').trim().isNotEmpty ||
          (e['phone'] ?? '').trim().isNotEmpty)
          .map((e) => {
        'name': (e['name'] ?? '').trim(),
        'phone': (e['phone'] ?? '').trim(),
        'relation': (e['relation'] ?? '').trim(),
      })
          .toList();

      if (validContacts.isNotEmpty) {
        body['emergency_contacts'] = validContacts;
      }

      print('UPDATE BODY: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('UPDATE RESPONSE: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final staffData = json['data'] as Map<String, dynamic>?;

        emit(AddStaffState(
          success: true,
          message: json['message']?.toString() ?? 'Staff updated successfully',
          updatedStaff: staffData != null ? StaffDetailModel.fromJson(staffData) : null,
        ));
      } else {
        emit(AddStaffState(error: _parseError(response)));
      }
    } catch (e, stack) {
      print('Update Staff Exception: $e');
      print('Stack: $stack');
      emit(AddStaffState(error: e.toString()));
    }
  }

  // Future<void> update({
  //   required String schoolId,
  //   required String uuid,
  //   required Map<String, dynamic> fields,
  //   required List<Map<String, String>> emergencyContacts,
  //   String? roleId,
  // }) async {
  //   emit(const AddStaffState(loading: true));
  //   try {
  //     final token = await UserSecureStorage.fetchToken();
  //
  //     final url = Config.url(Routes.updateStaff(schoolId, uuid));
  //     print('UPDATE STAFF URL: $url');
  //
  //     final body = <String, dynamic>{};
  //
  //     _addIfNotEmpty(body, 'name', fields['name']);
  //     _addIfNotEmpty(body, 'email', fields['email']);
  //     _addIfNotEmpty(body, 'phone', fields['phone']);
  //     _addIfNotEmpty(body, 'designation', fields['designation']);
  //     _addIfNotEmpty(body, 'department', fields['department']);
  //     _addIfNotEmpty(body, 'login_id', fields['login_id']);
  //     _addIfNotEmpty(body, 'whatsapp_phone',
  //         fields['whatsapp'] ?? fields['whatsapp_phone']);
  //     _addIfNotEmpty(body, 'father_name', fields['father_name']);
  //     _addIfNotEmpty(body, 'mother_name', fields['mother_name']);
  //     _addIfNotEmpty(body, 'husband_name', fields['husband_name']);
  //     _addIfNotEmpty(body, 'dob', _convertDate(fields['date_of_birth']));
  //     _addIfNotEmpty(body, 'date_of_joining',
  //         _convertDate(fields['date_of_joining']));
  //     _addIfNotEmpty(body, 'address', fields['address']);
  //     _addIfNotEmpty(body, 'pincode', fields['pincode']);
  //     _addIfNotEmpty(body, 'employee_id', fields['employee_id']);
  //     _addIfNotEmpty(body, 'national_code', fields['national_code']);
  //
  //     ///  MOST IMPORTANT FIX (ROLE MUST BE ARRAY)
  //     final roleRaw = roleId ?? fields['role'];
  //     if (roleRaw != null && roleRaw.toString().isNotEmpty) {
  //       final roleInt = int.tryParse(roleRaw.toString());
  //       if (roleInt != null) {
  //         body['role'] = [roleInt];
  //       }
  //     }
  //
  //     /// gender
  //     final gender = fields['gender']?.toString().trim() ?? '';
  //     if (gender.isNotEmpty &&
  //         gender.toLowerCase() != '-select gender-') {
  //       body['gender'] = gender.toLowerCase();
  //     }
  //
  //     /// blood group
  //     final bg = fields['blood_group']?.toString().trim() ?? '';
  //     if (bg.isNotEmpty && bg != 'Select Blood Group') {
  //       body['blood_group'] = bg;
  //     }
  //
  //     /// emergency contacts
  //     final validContacts = emergencyContacts
  //         .where((e) =>
  //     (e['name'] ?? '').isNotEmpty ||
  //         (e['phone'] ?? '').isNotEmpty)
  //         .map((e) => {
  //       'name': e['name'] ?? '',
  //       'phone': e['phone'] ?? '',
  //       'relation': e['relation'] ?? '',
  //     })
  //         .toList();
  //
  //     body['emergency_contacts'] = validContacts;
  //
  //     print('FINAL UPDATE BODY: $body');
  //
  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     print('UPDATE RESPONSE: ${response.statusCode} ${response.body}');
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final json = jsonDecode(response.body) as Map<String, dynamic>;
  //       final staffData = json['data'] as Map<String, dynamic>?;
  //
  //       emit(AddStaffState(
  //         success: true,
  //         message:
  //         json['message']?.toString() ?? 'Staff updated successfully',
  //         updatedStaff: staffData != null
  //             ? StaffDetailModel.fromJson(staffData)
  //             : null,
  //       ));
  //     } else {
  //       emit(AddStaffState(error: _parseError(response)));
  //     }
  //   } catch (e) {
  //     print('UPDATE STAFF EXCEPTION: $e');
  //     emit(AddStaffState(error: e.toString()));
  //   }
  // }

  void _addIfNotEmpty(
      Map<String, dynamic> body, String key, dynamic value) {
    if (value != null && value.toString().isNotEmpty) {
      body[key] = value;
    }
  }

  String? _convertDate(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    final parts = str.split(RegExp(r'[./\-]'));
    if (parts.length == 3) {
      if (parts[0].length == 4) return str;
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return str;
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

    String msg = json['message'] ??
        'Request failed with status ${response.statusCode}';

    final errors = json['errors'] as Map<String, dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final errorMessages = errors.values
          .expand((v) => v is List ? v : [v])
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

  Map<String, dynamic> _buildBody(
      String schoolId, Map<String, dynamic> fields) {
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

    fields.forEach((key, value) {
      if (value == null) return;
      final str = value.toString().trim();
      if (str.isEmpty) return;

      switch (key) {
        case 'date_of_birth':
        case 'dob':
          body['dob'] = convertDate(str);
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
          if (int.tryParse(str) != null) body['role'] = str;
          break;
        default:
          body[key] = str;
      }
    });

    return body;
  }
}