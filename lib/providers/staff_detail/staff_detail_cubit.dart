import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/staff/StaffDetailModel.dart';

class StaffDetailState {
  final bool loading;
  final StaffDetailModel? staff;
  final String? error;

  const StaffDetailState({this.loading = false, this.staff, this.error});

  StaffDetailState copyWith({bool? loading, StaffDetailModel? staff, String? error}) =>
      StaffDetailState(
        loading: loading ?? this.loading,
        staff: staff ?? this.staff,
        error: error,
      );
}

class StaffDetailCubit extends Cubit<StaffDetailState> {
  StaffDetailCubit() : super(const StaffDetailState());

  void emitUpdated(StaffDetailModel staff) {
    emit(state.copyWith(loading: false, staff: staff));
  }

  Future<void> load(String schoolId, String uuid) async {    emit(state.copyWith(loading: true, error: null));
    try {
      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';
      final url = '${Config.baseUrl}${Routes.getStaffDetail(schoolId, uuid, isPartner: isPartner)}';
      print('Staff detail URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      print('Staff detail status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final staffJson = json['data']?['staff'] as Map<String, dynamic>?;
        if (staffJson != null) {
          emit(state.copyWith(loading: false, staff: StaffDetailModel.fromJson(staffJson)));
        } else {
          emit(state.copyWith(loading: false, error: 'Staff data not found'));
        }
      } else {
        emit(state.copyWith(loading: false, error: 'Failed to load staff (${response.statusCode})'));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
