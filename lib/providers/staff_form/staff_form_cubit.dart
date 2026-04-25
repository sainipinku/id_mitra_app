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
  final List<StaffRole> roles;
  final String? error;

  const StaffFormState({
    this.loading = false,
    this.fields = const [],
    this.roles = const [],
    this.error,
  });

  StaffFormState copyWith({
    bool? loading,
    List<StudentFormField>? fields,
    List<StaffRole>? roles,
    String? error,
  }) =>
      StaffFormState(
        loading: loading ?? this.loading,
        fields: fields ?? this.fields,
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
      print('=== USER ROLE: $role | isPartner: $isPartner | schoolId: $schoolId');
      final headers = {'Authorization': 'Bearer $token', 'Accept': 'application/json'};

      // Fetch both in parallel
      final results = await Future.wait([
        http.get(Uri.parse('${Config.baseUrl}${Routes.getStaffFormFields(schoolId, isPartner: isPartner)}'), headers: headers),
        http.get(Uri.parse('${Config.baseUrl}${Routes.getStaffRoles(schoolId, isPartner: isPartner)}'), headers: headers),
      ]);

      final fieldsResp = results[0];
      final rolesResp = results[1];

      List<StudentFormField> fields = [];
      print('=== FIELDS API STATUS: ${fieldsResp.statusCode}');
      if (fieldsResp.statusCode == 200) {
        final json = jsonDecode(fieldsResp.body);
        final List rawFields = json['data']?['fields'] ?? [];
        fields = rawFields
            .map((e) => StudentFormField.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        print('=== FIELDS: ${fields.map((f) => '${f.name}(${f.type})').toList()}');
      }

      List<StaffRole> roles = [];
      print('=== ROLES API STATUS: ${rolesResp.statusCode}');
      print('=== ROLES API BODY: ${rolesResp.body}');
      if (rolesResp.statusCode == 200) {
        final json = jsonDecode(rolesResp.body);
        print('=== ROLES JSON KEYS: ${json.keys}');
        print('=== ROLES DATA: ${json['data']}');
        // Try multiple possible structures
        List rawRoles = [];
        if (json['data'] is List) {
          rawRoles = json['data'];
        } else if (json['data'] is Map && json['data']['roles'] is List) {
          rawRoles = json['data']['roles'];
        } else if (json['roles'] is List) {
          rawRoles = json['roles'];
        } else if (json['data'] is Map && json['data']['data'] is List) {
          rawRoles = json['data']['data'];
        }
        print('=== RAW ROLES COUNT: ${rawRoles.length}');
        roles = rawRoles.map((e) => StaffRole.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      emit(state.copyWith(loading: false, fields: fields, roles: roles));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
