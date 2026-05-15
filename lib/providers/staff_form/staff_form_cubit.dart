import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';

class StaffRole {
  final int id;
  final String uuid;
  final String name;

  const StaffRole({required this.id, required this.uuid, required this.name});

  factory StaffRole.fromJson(Map<String, dynamic> json) => StaffRole(
    id: json['id'] ?? 0,
    uuid: json['uuid'] ?? '',
    name: json['name'] ?? '',
  );
}

class StaffFormState {
  final bool loading;
  final bool saving;
  final List<StudentFormField> fields;
  final List<StudentFormField> availableFields;
  final List<StaffRole> roles;
  final String schoolName;
  final String? error;
  final String? successMessage;

  const StaffFormState({
    this.loading = false,
    this.saving = false,
    this.fields = const [],
    this.availableFields = const [],
    this.roles = const [],
    this.schoolName = '',
    this.error,
    this.successMessage,
  });

  StaffFormState copyWith({
    bool? loading,
    bool? saving,
    List<StudentFormField>? fields,
    List<StudentFormField>? availableFields,
    List<StaffRole>? roles,
    String? schoolName,
    String? error,
    String? successMessage,
  }) =>
      StaffFormState(
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        fields: fields ?? this.fields,
        availableFields: availableFields ?? this.availableFields,
        roles: roles ?? this.roles,
        schoolName: schoolName ?? this.schoolName,
        error: error,
        successMessage: successMessage,
      );
}

const List<Map<String, dynamic>> _kAllAvailableStaffFields = [
  {
    'name': 'designation',
    'label': 'Designation',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 1,
  },
  {
    'name': 'department',
    'label': 'Department',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 2,
  },
  {
    'name': 'name',
    'label': 'Name',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': true,
    'order': 3,
  },
  {
    'name': 'phone',
    'label': 'Phone',
    'type': 'phone',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': true,
    'order': 4,
  },
  {
    'name': 'email',
    'label': 'Email',
    'type': 'email',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 5,
  },
  {
    'name': 'role',
    'label': 'Role',
    'type': 'select',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': true,
    'order': 6,
  },
  {
    'name': 'password',
    'label': 'Password',
    'type': 'password',
    'group': 'login',
    'group_label': 'Login Details',
    'required': false,
    'order': 7,
  },
  {
    'name': 'password_confirmation',
    'label': 'Confirm Password',
    'type': 'password',
    'group': 'login',
    'group_label': 'Login Details',
    'required': false,
    'order': 8,
  },
  {
    'name': 'whatsapp_phone',
    'label': 'WhatsApp Phone',
    'type': 'phone',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 9,
  },
  {
    'name': 'date_of_birth',
    'label': 'Date of Birth',
    'type': 'date',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 10,
  },
  {
    'name': 'date_of_joining',
    'label': 'Date of Joining',
    'type': 'date',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 11,
  },
  {
    'name': 'gender',
    'label': 'Gender',
    'type': 'select',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 12,
  },
  {
    'name': 'blood_group',
    'label': 'Blood Group',
    'type': 'select',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 13,
  },
  {
    'name': 'address',
    'label': 'Address',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 14,
  },
  {
    'name': 'pincode',
    'label': 'Pincode',
    'type': 'digits',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 15,
  },
  {
    'name': 'employee_id',
    'label': 'Employee ID',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 16,
  },
  {
    'name': 'national_code',
    'label': 'National Code',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Staff Details',
    'required': false,
    'order': 17,
  },
  {
    'name': 'father_name',
    'label': 'Father Name',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Personal Details',
    'required': false,
    'order': 18,
  },
  {
    'name': 'mother_name',
    'label': 'Mother Name',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Personal Details',
    'required': false,
    'order': 19,
  },
  {
    'name': 'husband_name',
    'label': 'Husband Name',
    'type': 'text',
    'group': 'staff',
    'group_label': 'Personal Details',
    'required': false,
    'order': 20,
  },

];

List<StudentFormField> get _masterAvailableStaffFields =>
    _kAllAvailableStaffFields
        .map((e) => StudentFormField.fromJson(Map<String, dynamic>.from(e)))
        .toList();

class StaffFormCubit extends Cubit<StaffFormState> {
  StaffFormCubit() : super(const StaffFormState());

  String _schoolId = '';

  void clearMessages() {
    emit(StaffFormState(
      loading: state.loading,
      saving: state.saving,
      fields: state.fields,
      availableFields: state.availableFields,
      roles: state.roles,
      schoolName: state.schoolName,
      error: null,
      successMessage: null,
    ));
  }

  Future<void> loadFields(String schoolId, {String schoolName = ''}) async {
    _schoolId = schoolId;
    emit(state.copyWith(loading: true, error: null, schoolName: schoolName));

    try {
      final token = await UserSecureStorage.fetchToken();
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final fieldsUrl =
          '${Config.baseUrl}auth/school/$schoolId/form-fields/staff';
      print('Staff Fields Api Url: $fieldsUrl');

      final fieldsResp =
      await http.get(Uri.parse(fieldsUrl), headers: headers);
      print('STAFF FIELDS API STATUS: ${fieldsResp.statusCode}');
      print('STAFF FIELDS BODY: ${fieldsResp.body}');

      if (fieldsResp.statusCode != 200) {
        emit(state.copyWith(
          loading: false,
          error: 'Failed to load staff form fields (${fieldsResp.statusCode})',
        ));
        return;
      }

      final json = jsonDecode(fieldsResp.body);
      final data = json['data'] ?? {};

      final List rawFields = data['fields'] ?? [];
      final fields = rawFields
          .map((e) =>
          StudentFormField.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      final List rawAvailable =
          data['available_fields'] ?? data['available_staff_form_fields'] ?? [];

      final availableFields = rawAvailable.isNotEmpty
          ? (rawAvailable
          .map((e) =>
          StudentFormField.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)))
          : _masterAvailableStaffFields; // ← static fallback

      List<StaffRole> roles = [];
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';

      final rolesUrls = [
        Config.url(Routes.getStaffRoles(schoolId, isPartner: isPartner)),
        Config.url(Routes.getStaffRoles(schoolId, isPartner: !isPartner)),
      ];

      for (final rolesUrl in rolesUrls) {
        print('=== ROLES API URL: $rolesUrl');
        try {
          final rolesResp =
          await http.get(Uri.parse(rolesUrl), headers: headers);
          if (rolesResp.statusCode == 200) {
            final rJson = jsonDecode(rolesResp.body);
            final rawRoles = _extractRolesList(rJson);
            roles = rawRoles
                .map((e) =>
                StaffRole.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            if (roles.isNotEmpty) break;
          }
        } catch (e) {
          print('Roles fetch error: $e');
        }
      }

      emit(state.copyWith(
        loading: false,
        fields: fields,
        availableFields: availableFields,
        roles: roles,
      ));
    } catch (e) {
      print('STAFF FIELDS EXCEPTION: $e');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> updateStaffFormFields(
      List<StudentFormField> updatedFields) async {
    emit(state.copyWith(saving: true, error: null, successMessage: null));

    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}auth/school/$_schoolId/form-fields/staff';
      print('UPDATE STAFF FORM FIELDS URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fields': updatedFields
              .map((f) => {
            'name': f.name,
            'label': f.label,
            'group': f.group,
            'group_label': f.groupLabel,
            'type': f.type,
            'required': f.required,
            'order': f.order,
          })
              .toList(),
        }),
      );

      print(
          'UPDATE STAFF RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        emit(state.copyWith(
          saving: false,
          successMessage:
          json['message'] ?? 'Staff form fields updated successfully',
          fields: updatedFields,
        ));
      } else {
        emit(state.copyWith(
          saving: false,
          error: 'Update failed: ${response.statusCode}',
        ));
      }
    } catch (e) {
      print('UPDATE STAFF EXCEPTION: $e');
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  List _extractRolesList(dynamic json) {
    if (json == null) return [];
    if (json is List) return json;
    if (json is! Map) return [];
    for (final key in ['data', 'roles', 'items', 'result', 'results']) {
      final val = json[key];
      if (val is List && val.isNotEmpty) return val;
      if (val is Map) {
        for (final innerKey in [
          'data',
          'roles',
          'items',
          'result',
          'results',
          'list'
        ]) {
          final inner = val[innerKey];
          if (inner is List && inner.isNotEmpty) return inner;
        }
      }
    }
    return [];
  }
}