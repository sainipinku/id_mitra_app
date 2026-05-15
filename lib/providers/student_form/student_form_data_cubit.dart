import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';

import '../../models/add_student/StudentFormDataModel.dart';

class StudentFormDataState {
  final bool loading;
  final StudentFormDataModel? data;
  final String? error;
  const StudentFormDataState({this.loading = false, this.data, this.error});
}

class StudentFormDataCubit extends Cubit<StudentFormDataState> {
  StudentFormDataCubit() : super(const StudentFormDataState());

  Future<void> load(String schoolId) async {
    emit(const StudentFormDataState(loading: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}auth/school/$schoolId/students/form-data';
      print('form-data URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('form-data response: $decoded');
        final model = StudentFormDataModel.fromJson(decoded);
        print('Classes loaded: ${model.classes.length}');
        for (final c in model.classes) {
          print('  Class: ${c.nameWithPrefix} (id=${c.id}) sections=${c.sections.map((s) => '${s.name}(${s.id})').toList()} sectionsIds=${c.sectionsIds}');
        }
        emit(StudentFormDataState(data: model));
      } else {
        emit(StudentFormDataState(error: 'Failed: ${response.statusCode}'));
      }
    } catch (e) {
      emit(StudentFormDataState(error: e.toString()));
    }
  }
}
