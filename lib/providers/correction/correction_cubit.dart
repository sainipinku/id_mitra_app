import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/correction/CorrectionListModel.dart';
import 'package:idmitra/providers/correction/correction_state.dart';

class CorrectionCubit extends Cubit<CorrectionState> {
  CorrectionCubit() : super(const CorrectionState());

  final ApiManager _api = ApiManager();

  Future<void> fetchCorrectionList({
    required String schoolId,
    bool isSchool = false,
    bool isLoadMore = false,
    String search = '',
    String classId = '',
    String gender = '',
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
      String url = '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists?page=$currentPage&per_page=50';
      if (search.isNotEmpty) url += '&search=$search';
      if (classId.isNotEmpty) url += '&class_id=$classId';
      if (gender.isNotEmpty) url += '&gender=$gender';

      var response = await _api.getRequest(url);

      if (response != null && response.statusCode == 403) {
        final partnerUrl = '${Config.baseUrl}auth/partner/school/$schoolId/orders/correction-lists?page=$currentPage&per_page=50${search.isNotEmpty ? '&search=$search' : ''}${classId.isNotEmpty ? '&class_id=$classId' : ''}${gender.isNotEmpty ? '&gender=$gender' : ''}';
        response = await _api.getRequest(partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(loading: false, error: 'Failed to load correction list'));
        return;
      }

      final json = jsonDecode(response.body);
      if (json['success'] != true) {
        emit(state.copyWith(loading: false, error: json['message'] ?? 'Something went wrong'));
        return;
      }

      final data = json['data'] as Map<String, dynamic>?;
      final checklists = data?['checklists'] as Map<String, dynamic>?;
      final List rawList = checklists?['data'] ?? [];
      final int lastPage = checklists?['last_page'] ?? 1;
      final int respPage = checklists?['current_page'] ?? 1;

      final newItems = rawList
          .map((e) => CorrectionItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final updatedList = isLoadMore ? [...state.items, ...newItems] : newItems;

      emit(state.copyWith(
        loading: false,
        items: updatedList,
        page: respPage + 1,
        hasMore: respPage < lastPage,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void toggleSelection(int id) {
    final current = Set<int>.from(state.selectedIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    emit(state.copyWith(selectedIds: current));
  }

  void selectAll() {
    final allIds = state.items.map((e) => e.id).toSet();
    emit(state.copyWith(selectedIds: allIds));
  }

  void clearSelection() {
    emit(state.copyWith(selectedIds: {}));
  }
}
