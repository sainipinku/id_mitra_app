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
  final List<StudentFormField> fields;
  final List<StudentFormField> availableFields;
  final List<StaffRole> roles;
  final String? error;

  const StaffFormState({
    this.loading = false,
    this.fields = const [],
    this.availableFields = const [],
    this.roles = const [],
    this.error,
  });

  StaffFormState copyWith({
    bool? loading,
    List<StudentFormField>? fields,
    List<StudentFormField>? availableFields,
    List<StaffRole>? roles,
    String? error,
  }) => StaffFormState(
    loading: loading ?? this.loading,
    fields: fields ?? this.fields,
    availableFields: availableFields ?? this.availableFields,
    roles: roles ?? this.roles,
    error: error,
  );
}

class StaffFormCubit extends Cubit<StaffFormState> {
  StaffFormCubit() : super(const StaffFormState());

  Future<void> loadFields(String schoolId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';


      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      List<StudentFormField> fields = [];
      List<StudentFormField> availableFields = [];
      List<StaffRole> roles = [];

      if (isPartner) {
        fields = _partnerDefaultFields();
        availableFields = List.from(fields);

      } else {
        final fieldsUrl = Config.url(
          Routes.getStaffFormFields(schoolId, isPartner: false),
        );
        print('=== FIELDS API URL: $fieldsUrl');

        final fieldsResp = await http.get(
          Uri.parse(fieldsUrl),
          headers: headers,
        );
        print('=== FIELDS API STATUS: ${fieldsResp.statusCode}');

        if (fieldsResp.statusCode == 200) {
          final json = jsonDecode(fieldsResp.body);
          final data = json['data'] ?? {};
          final List rawFields = data['fields'] ?? [];

          fields =
              rawFields
                  .map(
                    (e) =>
                        StudentFormField.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
                ..sort((a, b) => a.order.compareTo(b.order));

          final List rawAvailable =
              data['available_fields'] ??
              data['available_staff_form_fields'] ??
              [];

          availableFields = rawAvailable.isNotEmpty
              ? (rawAvailable
                    .map(
                      (e) => StudentFormField.fromJson(
                        Map<String, dynamic>.from(e),
                      ),
                    )
                    .toList()
                  ..sort((a, b) => a.order.compareTo(b.order)))
              : List.from(fields);

        } else {
          emit(
            state.copyWith(
              loading: false,
              error: 'Failed to load form fields (${fieldsResp.statusCode})',
            ),
          );
          return;
        }
      }

      final rolesUrls = [
        Config.url(Routes.getStaffRoles(schoolId, isPartner: isPartner)),
        Config.url(Routes.getStaffRoles(schoolId, isPartner: !isPartner)),
      ];

      for (final rolesUrl in rolesUrls) {
        print('=== ROLES API URL: $rolesUrl');
        try {
          final rolesResp = await http.get(
            Uri.parse(rolesUrl),
            headers: headers,
          );
          if (rolesResp.statusCode == 200) {
            final rJson = jsonDecode(rolesResp.body);
            List rawRoles = _extractRolesList(rJson);
            roles = rawRoles
                .map((e) => StaffRole.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            if (roles.isNotEmpty) break;
          }
        } catch (e) {
        }
      }

      emit(
        state.copyWith(
          loading: false,
          fields: fields,
          availableFields: availableFields,
          roles: roles,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
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
        for (final innerKey in ['data', 'roles', 'items', 'result', 'results', 'list']) {
          final inner = val[innerKey];
          if (inner is List && inner.isNotEmpty) return inner;
        }
      }
    }
    return [];
  }

  List<StudentFormField> _partnerDefaultFields() {
    return [
      StudentFormField(
        name: 'designation',
        label: 'Designation',
        type: 'text',
        required: false,
        order: 1,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'department',
        label: 'Department',
        type: 'text',
        required: false,
        order: 2,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'name',
        label: 'Name',
        type: 'text',
        required: true,
        order: 3,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'phone',
        label: 'Phone',
        type: 'phone',
        required: true,
        order: 4,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'email',
        label: 'Email',
        type: 'email',
        required: false,
        order: 5,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'role',
        label: 'Role',
        type: 'select',
        required: true,
        order: 6,
        group: 'staff_details',
        groupLabel: 'Staff Details',
      ),
      StudentFormField(
        name: 'password',
        label: 'Password',
        type: 'password',
        required: false,
        order: 7,
        group: 'login_details',
        groupLabel: 'Login Details',
      ),
      StudentFormField(
        name: 'password_confirmation',
        label: 'Confirm Password',
        type: 'password',
        required: false,
        order: 8,
        group: 'login_details',
        groupLabel: 'Login Details',
      ),
    ];
  }
}
