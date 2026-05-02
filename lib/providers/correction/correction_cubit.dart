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

  Future<void> sendOrder({required String schoolId}) async {
    if (state.selectedIds.isEmpty) return;
    emit(state.copyWith(sendOrderLoading: true, clearSendOrderError: true, sendOrderSuccess: false));
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists/send';
      final body = {'checklist_ids': state.selectedIds.toList()};
      final response = await _api.postRequest(body, url);
      if (response == null) {
        emit(state.copyWith(sendOrderLoading: false, sendOrderError: 'Failed to send order'));
        return;
      }
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        emit(state.copyWith(
          sendOrderLoading: false,
          sendOrderSuccess: true,
          selectedIds: {},
        ));
      } else {
        emit(state.copyWith(
          sendOrderLoading: false,
          sendOrderError: json['message'] ?? 'Failed to send order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(sendOrderLoading: false, sendOrderError: e.toString()));
    }
  }

  Future<void> fetchDownloadColumns({
    required String schoolId,
    bool isSchool = false,
  }) async {
    emit(state.copyWith(columnsLoading: true));
    try {
      String url = '${Config.baseUrl}auth/school/$schoolId/form-fields';
      var response = await _api.getRequest(url);

      if (response != null && response.statusCode == 403) {
        url = '${Config.baseUrl}auth/partner/school/$schoolId/student-form-fields';
        response = await _api.getRequest(url);
      }

      if (response == null) {
        emit(state.copyWith(columnsLoading: false));
        return;
      }

      final json = jsonDecode(response.body);
      final data = json['data'] ?? json['props']?['school'] ?? {};

      List rawFields = [];
      if (data['student_form_fields'] is List) {
        rawFields = data['student_form_fields'] as List;
      } else if (data['available_student_form_fields'] is List) {
        rawFields = data['available_student_form_fields'] as List;
      } else if (json['data'] is List) {
        rawFields = json['data'] as List;
      }

      final columns = rawFields
          .where((e) => e['name'] != null && e['label'] != null)
          .map((e) => DownloadColumn(
                key: e['name'].toString(),
                label: e['label'].toString(),
              ))
          .toList();

      emit(state.copyWith(columnsLoading: false, downloadColumns: columns));
    } catch (e) {
      emit(state.copyWith(columnsLoading: false));
    }
  }

  Future<void> downloadCorrectionList({
    required String schoolId,
    required List<String> columns,
    required String printType,
  }) async {
    emit(state.copyWith(downloadLoading: true, clearDownloadError: true, clearDownloadUrl: true));
    try {
      String url = '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists/download';
      final body = {
        'columns': columns,
        'print_type': printType,
      };
      var response = await _api.postRequest(body, url);

      if (response != null && response.statusCode == 403) {
        final partnerUrl = '${Config.baseUrl}auth/partner/school/$schoolId/orders/correction-lists/download';
        response = await _api.postRequest(body, partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(downloadLoading: false, downloadError: 'Failed to download. Please try again.'));
        return;
      }

      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final fileUrl = json['data']?['url'] ?? json['data']?['file_url'] ?? json['url'] ?? '';
        emit(state.copyWith(downloadLoading: false, downloadUrl: fileUrl.toString()));
      } else {
        emit(state.copyWith(
          downloadLoading: false,
          downloadError: json['message'] ?? 'Download failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(downloadLoading: false, downloadError: e.toString()));
    }
  }
}
