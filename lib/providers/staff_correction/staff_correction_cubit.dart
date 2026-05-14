import 'dart:convert';
import 'dart:typed_data';
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

      print("=== STAFF CORRECTION RESPONSE ===");
      print(response.body);
      print("=================================");

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

      if (rawList.isNotEmpty) {
        print("=== StaffCorrectionItem sample keys: ${(rawList.first as Map).keys.toList()}");
        print("=== StaffCorrectionItem sample: ${rawList.first}");
      }

      final updated = isLoadMore ? [...state.items, ...newItems] : newItems;

      print("=== Parsed ${newItems.length} StaffCorrectionItems ===");
      for (final item in newItems) {
        print("  id=${item.id} uuid=${item.uuid} staff=${item.staff?.name} oldData=${item.oldData?.name} effectiveStaff=${item.effectiveStaff?.name}");
      }

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

  Future<void> createStaffOrder({
    required String schoolId,
    required String cardType,
    required List<String> cardUsers,
  }) async {
    if (cardUsers.isEmpty) {
      emit(state.copyWith(sendOrderError: 'No staff selected'));
      return;
    }

    emit(state.copyWith(
      sendOrderLoading: true,
      clearSendOrderError: true,
      sendOrderSuccess: false,
    ));

    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/staff/orders';
      final body = <String, dynamic>{
        'card_type': cardType,
        'card_users': cardUsers,
      };

      print("=== createStaffOrder REQUEST ===");
      print("URL: $url");
      print("BODY: ${jsonEncode(body)}");

      final response = await _api.postRequest(body, url);

      print("=== createStaffOrder RESPONSE ===");
      print("STATUS: ${response?.statusCode}");
      print("BODY: ${response?.body}");
      print("================================");

      if (response == null) {
        emit(state.copyWith(
          sendOrderLoading: false,
          sendOrderError: 'Failed to create order',
        ));
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
          sendOrderError: json['message'] ?? 'Failed to create order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        sendOrderLoading: false,
        sendOrderError: e.toString(),
      ));
    }
  }

  Future<void> processOrder({
    required String schoolId,
    String cardType = '',
    List<String> cardFor = const [],
    List<String>? staffUuids, // optional: pass directly from Staff list tab
    String listType = '',
    String processType = 'create',
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
        'processType': processType.isNotEmpty ? processType : 'create',
        'list_type': listType.isNotEmpty ? listType : 'selected',
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

  /// Fetches staff form fields to use as download columns
  Future<void> fetchStaffDownloadColumns({required String schoolId}) async {
    emit(state.copyWith(columnsLoading: true));
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/form-fields/staff';
      var response = await _api.getRequest(url);

      if (response == null) {
        emit(state.copyWith(columnsLoading: false));
        return;
      }

      final json = jsonDecode(response.body);
      final data = json['data'] ?? {};

      List rawFields = [];
      if (data['staff_form_fields'] is List) {
        rawFields = data['staff_form_fields'] as List;
      } else if (data['available_staff_form_fields'] is List) {
        rawFields = data['available_staff_form_fields'] as List;
      } else if (json['data'] is List) {
        rawFields = json['data'] as List;
      }

      // Fallback: default staff fields if API returns nothing
      if (rawFields.isEmpty) {
        rawFields = [
          {'name': 'name', 'label': 'Name'},
          {'name': 'father_name', 'label': 'Father Name'},
          {'name': 'phone', 'label': 'Phone'},
          {'name': 'dob', 'label': 'DOB'},
          {'name': 'gender', 'label': 'Gender'},
          {'name': 'email', 'label': 'Email'},
          {'name': 'photo', 'label': 'Photo'},
          {'name': 'designation', 'label': 'Designation'},
          {'name': 'department', 'label': 'Department'},
          {'name': 'employee_id', 'label': 'Employee ID'},
          {'name': 'address', 'label': 'Address'},
        ];
      }

      final columns = rawFields
          .where((e) => e['name'] != null && e['label'] != null)
          .map((e) => StaffDownloadColumn(
        key: e['name'].toString(),
        label: e['label'].toString(),
      ))
          .toList();

      emit(state.copyWith(columnsLoading: false, downloadColumns: columns));
    } catch (e) {
      emit(state.copyWith(columnsLoading: false));
    }
  }

  /// POST auth/school/{schoolId}/staff/correction-lists/download
  /// Body: { "ids": [...uuids], "selected": [...fields] }
  /// Returns PDF bytes on success, null on failure.
  Future<Uint8List?> downloadStaffCorrectionList({
    required String schoolId,
    required List<String> ids,
    required List<String> selected,
  }) async {
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/staff/correction-lists/download';
      final body = <String, dynamic>{
        'ids': ids,
        'selected': selected,
      };

      print("=== downloadStaffCorrectionList REQUEST ===");
      print("URL: $url");
      print("BODY: ${jsonEncode(body)}");

      final response = await _api.postRequest(body, url);

      print("=== downloadStaffCorrectionList RESPONSE ===");
      print("STATUS: ${response?.statusCode}");
      print("CONTENT-TYPE: ${response?.headers['content-type']}");
      print("BODY LENGTH: ${response?.bodyBytes.length}");

      if (response == null) return null;

      // If response is PDF bytes directly
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('application/pdf') ||
          contentType.contains('application/octet-stream') ||
          (response.bodyBytes.isNotEmpty && response.bodyBytes.first == 0x25)) {
        return Uint8List.fromList(response.bodyBytes);
      }

      // If response is JSON with a file URL
      try {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final fileUrl = json['data']?['url'] ?? json['data']?['file_url'] ?? '';
          if (fileUrl.toString().isNotEmpty) {
            final res = await _api.getRequest(fileUrl.toString());
            if (res != null && res.bodyBytes.isNotEmpty) {
              return Uint8List.fromList(res.bodyBytes);
            }
          }
        }
      } catch (_) {}

      return null;
    } catch (e) {
      print('downloadStaffCorrectionList error: $e');
      return null;
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
