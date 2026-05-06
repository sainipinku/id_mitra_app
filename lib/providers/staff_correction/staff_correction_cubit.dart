import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'staff_correction_state.dart';

export 'staff_correction_state.dart';

class StaffCorrectionCubit extends Cubit<StaffCorrectionState> {
  StaffCorrectionCubit() : super(const StaffCorrectionState());

  final ApiManager _api = ApiManager();

  Future<void> fetchStaffCorrection({
    required String schoolId,
    bool isLoadMore = false,
    String search = '',
  }) async {
    if (isLoadMore && (state.loading || !state.hasMore)) return;

    final currentPage = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        items: [],
        page: 1,
        hasMore: true,
        clearError: true,
      ));
    }

    try {
      String url =
          '${Config.baseUrl}auth/school/$schoolId/staff/correction-lists?page=$currentPage&per_page=50';
      if (search.isNotEmpty) url += '&search=$search';

      var response = await _api.getRequest(url);

      if (response != null && response.statusCode == 403) {
        String partnerUrl =
            '${Config.baseUrl}auth/partner/school/$schoolId/staff/correction-lists?page=$currentPage&per_page=50';
        if (search.isNotEmpty) partnerUrl += '&search=$search';
        response = await _api.getRequest(partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(loading: false, error: 'Failed to load staff correction list'));
        return;
      }

      final json = jsonDecode(response.body);
      if (json['success'] != true) {
        emit(state.copyWith(
          loading: false,
          error: json['message'] ?? 'Something went wrong',
        ));
        return;
      }

      final data = json['data'] as Map<String, dynamic>?;
      final listPage = (data?['list'] ?? data?['data']) as Map<String, dynamic>?;
      final List rawList = listPage?['data'] ?? (data?['data'] is List ? data!['data'] : []);
      final int lastPage = listPage?['last_page'] ?? 1;
      final int respPage = listPage?['current_page'] ?? 1;
      final int total = listPage?['total'] ?? rawList.length;

      final newItems = rawList
          .map((e) => StaffCorrectionItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final updated = isLoadMore ? [...state.items, ...newItems] : newItems;

      emit(state.copyWith(
        loading: false,
        items: updated,
        page: respPage + 1,
        hasMore: respPage < lastPage,
        total: total,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
