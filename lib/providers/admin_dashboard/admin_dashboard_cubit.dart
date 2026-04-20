import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/home/SchoolDashboardModel.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit() : super(AdminDashboardState());

  final ApiManager _api = ApiManager();

  Future<void> loadDashboard() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final response = await _api.getRequest(
        Config.baseUrl + Routes.getSchoolDashboard(),
      );
      if (response == null) {
        emit(state.copyWith(loading: false, error: 'No response from server'));
        return;
      }
      if (response.statusCode == 200) {
        final body = response.body as String;
        print('📊 Dashboard API Response: $body'); // debug - remove after fix
        final json = jsonDecode(body);
        final model = SchoolDashboardModel.fromJson(json);
        print('📊 Parsed students: ${model.data.summary.students}'); // debug
        emit(state.copyWith(loading: false, dashboard: model));
      } else {
        emit(state.copyWith(
          loading: false,
          error: 'Error ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
