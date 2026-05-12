import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
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
    emit(state.copyWith(selectedIds: state.items.map((e) => e.id).toSet()));
  }

  void clearSelection() {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> processOrder({
    required String schoolId,
    String cardType = '',
    List<String> cardFor = const [],
    List<String>? staffUuids, // optional: pass directly from Staff list tab
  }) async {
    List<String> selectedUuids;

    if (staffUuids != null && staffUuids.isNotEmpty) {
      selectedUuids = staffUuids;
    } else {
      if (state.selectedIds.isEmpty) return;
      selectedUuids = state.items
          .where((s) => state.selectedIds.contains(s.id) && s.uuid != null)
          .map((s) => s.uuid!)
          .toList();
    }

    if (selectedUuids.isEmpty) {
      emit(state.copyWith(sendOrderError: 'No valid items found for selected entries'));
      return;
    }

    emit(state.copyWith(sendOrderLoading: true, clearSendOrderError: true, sendOrderSuccess: false));
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/staff/correction-lists/process';
      final body = <String, dynamic>{
        'processType': 'create',
        'staff': selectedUuids,
        if (cardType.isNotEmpty) 'card_type': cardType,
        if (cardFor.isNotEmpty) 'card_for': cardFor,
      };
      final response = await _api.postRequest(body, url);
      if (response == null) {
        emit(state.copyWith(sendOrderLoading: false, sendOrderError: 'Failed to process order'));
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
          sendOrderError: json['message'] ?? 'Failed to process order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(sendOrderLoading: false, sendOrderError: e.toString()));
    }
  }

  Future<String?> uploadStaffPhoto({
    required String schoolId,
    required String uuid,
    required String imagePath,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.uploadStaffPhoto(schoolId, uuid)}';
      print('uploadStaffPhoto URL: $url');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('uploadStaffPhoto status: ${response.statusCode}');
      print('uploadStaffPhoto body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        String? newUrl = json['data']?['profile_photo_url'] as String?;
        if (newUrl != null) {
          final regex = RegExp(r'https?://');
          final matches = regex.allMatches(newUrl).toList();
          if (matches.length > 1) newUrl = newUrl.substring(matches.last.start);
          newUrl = newUrl
              .replaceAll('http://127.0.0.1:8000', 'https://idmitra.com')
              .replaceAll('http://localhost:8000', 'https://idmitra.com')
              .replaceAll('http://localhost', 'https://idmitra.com');
        }
        return newUrl;
      }
    } catch (e) {
      print('uploadStaffPhoto error: $e');
    }
    return null;
  }
}
