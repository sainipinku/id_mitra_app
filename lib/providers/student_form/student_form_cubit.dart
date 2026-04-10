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

  /// Called from StudentForm screen with school data + schoolId for sig fetch
  void loadFromModel({
    required List<StudentFormField> fields,
    required String schoolName,
    required String schoolId,
  }) {
    emit(state.copyWith(
      loading: false,
      fields: fields,
      schoolName: schoolName,
      error: null,
      successMessage: null,
    ));

    // Fetch sig + available fields from partner API
    _fetchSigAndAvailableFields(schoolId);
  }

  Future<void> _fetchSigAndAvailableFields(String schoolId) async {
    final token = await UserSecureStorage.fetchToken();

    // Try partner API to get sig for this school
    final sigUrl = '${Config.baseUrl}auth/partner/school/$schoolId/student-form-sig';
    print('Fetching sig: $sigUrl');

    final sigResp = await http.get(
      Uri.parse(sigUrl),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('Sig status: ${sigResp.statusCode}');

    if (sigResp.statusCode == 200) {
      final sigJson = jsonDecode(sigResp.body);
      _sig = sigJson['sig'] ?? sigJson['data']?['sig'] ?? '';
      print('Got sig: $_sig');

      if (_sig.isNotEmpty) {
        await _fetchAvailableFields(token);
      }
    } else {
      // Sig endpoint not found - try fetching via school detail
      print('Sig endpoint failed (${sigResp.statusCode}), trying school detail...');
      await _fetchSigFromSchoolDetail(schoolId, token);
    }
  }

  Future<void> _fetchSigFromSchoolDetail(String schoolId, String? token) async {
    final url = '${Config.baseUrl}auth/partner/schools/$schoolId';
    print('School detail: $url');

    final resp = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('School detail status: ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      // Try to find sig in response
      _sig = json['data']?['sig'] ??
          json['data']?['school']?['sig'] ??
          json['sig'] ?? '';
      print('School detail sig: $_sig');
      print('School detail keys: ${(json['data'] as Map?)?.keys.toList()}');
    }
  }

  Future<void> _fetchAvailableFields(String? token) async {
    final url = '${Config.schoolBaseUrl}school/configration/student-form-fields?sig=$_sig';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Inertia': 'true',
        'X-Inertia-Version': '',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    print('Available fields status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('<')) {
        print('Got HTML - sig invalid');
        return;
      }

      final jsonData = jsonDecode(body);

      // Parse sig from url field if not already set
      final urlField = jsonData['url'] as String? ?? '';
      if (_sig.isEmpty && urlField.contains('sig=')) {
        final uri = Uri.tryParse('https://idmitra.com$urlField');
        _sig = uri?.queryParameters['sig'] ?? '';
        print('Sig from url field: $_sig');
      }

      final school = jsonData['props']?['school'] ?? {};
      print('School keys: ${(school as Map).keys.toList()}');

      final List available = school['available_student_form_fields'] ?? [];
      print('Available fields: ${available.length}');

      if (available.isNotEmpty) {
        emit(state.copyWith(
          availableFields: available.map((e) => StudentFormField.fromJson(e)).toList(),
        ));
      }
    }
  }

  /// POST: save configuration
  Future<void> updateStudentFormFields(List<StudentFormField> updatedFields) async {
    if (_sig.isEmpty) {
      emit(state.copyWith(saving: false, error: 'Session token not available. Please wait and retry.'));
      return;
    }

    emit(state.copyWith(saving: true, error: null, successMessage: null));

    final token = await UserSecureStorage.fetchToken();
    final url = '${Config.schoolBaseUrl}school/configration/student-form-fields/update';

    final body = jsonEncode({
      'sig': _sig,
      'fields': updatedFields.map((f) => {
        'name': f.name,
        'label': f.label,
        'group': f.group,
        'group_label': f.groupLabel,
        'type': f.type,
        'required': f.required,
        'order': f.order,
      }).toList(),
    });

    print('POST $url');
    print('sig: $_sig');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-Inertia': 'true',
        'X-Inertia-Version': '',
      },
      body: body,
    );

    print('Update status: ${response.statusCode}');
    print('Update body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

    if (response.statusCode == 200) {
      final respBody = response.body.trim();
      if (respBody.startsWith('<')) {
        emit(state.copyWith(saving: false, error: 'Session expired'));
        return;
      }
      final jsonData = jsonDecode(respBody);
      final message = jsonData['message'] ?? 'Form fields updated successfully';
      final List respFields = jsonData['fields'] ?? [];
      final newFields = respFields.isNotEmpty
          ? respFields.map((e) => StudentFormField.fromJson(e)).toList()
          : updatedFields;

      emit(state.copyWith(
        saving: false,
        successMessage: message,
        fields: newFields,
      ));
    } else {
      emit(state.copyWith(saving: false, error: 'Update failed: ${response.statusCode}'));
    }
  }
}
