import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/correction/CorrectionListModel.dart';
import 'package:idmitra/providers/correction/correction_state.dart';
import 'package:path_provider/path_provider.dart';

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
      String url =
          '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists?page=$currentPage&per_page=50';

      if (search.isNotEmpty) url += '&search=$search';
      if (classId.isNotEmpty) url += '&class_id=$classId';
      if (gender.isNotEmpty) url += '&gender=$gender';

      var response = await _api.getRequest(url);

      if (response != null && response.statusCode == 403) {
        final partnerUrl =
            '${Config.baseUrl}auth/partner/school/$schoolId/orders/correction-lists?page=$currentPage&per_page=50'
            '${search.isNotEmpty ? '&search=$search' : ''}'
            '${classId.isNotEmpty ? '&class_id=$classId' : ''}'
            '${gender.isNotEmpty ? '&gender=$gender' : ''}';

        response = await _api.getRequest(partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(
          loading: false,
          error: 'Failed to load correction list',
        ));
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
      final checklists = data?['checklists'] as Map<String, dynamic>?;

      final List rawList = checklists?['data'] ?? [];

      final int lastPage = checklists?['last_page'] ?? 1;
      final int respPage = checklists?['current_page'] ?? 1;

      final newItems = rawList
          .map(
            (e) => CorrectionItem.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();

      final updatedList =
      isLoadMore ? [...state.items, ...newItems] : newItems;

      emit(state.copyWith(
        loading: false,
        items: updatedList,
        page: respPage + 1,
        hasMore: respPage < lastPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
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

  void toggleStudentSelection(int id) {
    final current = Set<int>.from(state.selectedStudentIds);

    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }

    emit(state.copyWith(selectedStudentIds: current));
  }

  void selectAllStudents() {
    final allIds = state.students.map((e) => e.id).toSet();

    emit(state.copyWith(selectedStudentIds: allIds));
  }

  void clearStudentSelection() {
    emit(state.copyWith(selectedStudentIds: {}));
  }

  void setSelectedClassIds(List<String> classIds) {
    emit(state.copyWith(selectedClassIds: classIds));
  }

  Future<void> processOrder({
    required String schoolId,
    String processType = 'create',
    String listType = 'class_wise',
    String cardType = '',
    List<String> cardFor = const [],
    List<String>? studentUuids, // optional: pass directly from Students tab
  }) async {
    List<String> selectedUuids;

    if (studentUuids != null && studentUuids.isNotEmpty) {
      selectedUuids = studentUuids;
    } else {
      if (state.selectedStudentIds.isEmpty) return;
      selectedUuids = state.students
          .where((s) =>
      state.selectedStudentIds.contains(s.id) &&
          s.student?.uuid != null &&
          s.student!.uuid!.isNotEmpty)
          .map((s) => s.student!.uuid!)
          .toList();
    }

    if (selectedUuids.isEmpty) {
      emit(state.copyWith(
          sendOrderError: 'No valid items found for selected entries'));
      return;
    }

    emit(state.copyWith(
        sendOrderLoading: true,
        clearSendOrderError: true,
        sendOrderSuccess: false));
    try {
      final url =
          '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists/process';
      final body = <String, dynamic>{
        'processType': processType,
        'listType': listType,
        'students': selectedUuids,
        if (cardType.isNotEmpty) 'card_type': cardType,
        if (cardFor.isNotEmpty) 'card_for': cardFor,
      };
      final response = await _api.postRequest(body, url);
      print("=== processOrder RESPONSE ===");
      print("URL: $url");
      print("BODY: ${jsonEncode(body)}");
      print("STATUS: ${response?.statusCode}");
      print("BODY: ${response?.body}");
      if (response == null) {
        emit(state.copyWith(
            sendOrderLoading: false,
            sendOrderError: 'Failed to process order'));
        return;
      }
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        emit(state.copyWith(
          sendOrderLoading: false,
          sendOrderSuccess: true,
          selectedStudentIds: {},
        ));
      } else {
        emit(state.copyWith(
          sendOrderLoading: false,
          sendOrderError: json['message'] ?? 'Failed to process order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          sendOrderLoading: false, sendOrderError: e.toString()));
    }
  }

  Future<void> createOrder({
    required String schoolId,
    String cardType = 'new',
    List<String> cardFor = const [],
    List<String>? studentUuids,
  }) async {
    List<String> selectedUuids = [];

    try {
      if (studentUuids != null && studentUuids.isNotEmpty) {
        selectedUuids = studentUuids.where((e) => e.trim().isNotEmpty).toList();
      } else {
        if (state.selectedStudentIds.isEmpty) {
          emit(state.copyWith(
            createOrderLoading: false,
            createOrderError: 'Please select students',
          ));
          return;
        }
        selectedUuids = state.students
            .where((s) =>
        state.selectedStudentIds.contains(s.id) &&
            s.uuid != null &&
            s.uuid!.trim().isNotEmpty)
            .map((s) => s.uuid!.trim())
            .toList();

        // Debug: log what we have
        print("=== createOrder debug ===");
        print("state.students count: ${state.students.length}");
        print("selectedStudentIds: ${state.selectedStudentIds}");
        for (final s in state.students.where((s) => state.selectedStudentIds.contains(s.id))) {
          print("item.id=${s.id} item.uuid=${s.uuid} student=${s.student} student.uuid=${s.student?.uuid}");
        }
        print("selectedUuids => $selectedUuids");
      }

      selectedUuids = selectedUuids.toSet().toList();

      if (selectedUuids.isEmpty) {
        emit(state.copyWith(
          createOrderLoading: false,
          createOrderError: 'No valid students found for selected entries',
        ));
        return;
      }

      emit(state.copyWith(
        createOrderLoading: true,
        clearCreateOrderError: true,
        createOrderSuccess: false,
      ));

      // POST auth/school/{schoolId}/orders
      final String url = '${Config.baseUrl}auth/school/$schoolId/orders';

      final Map<String, dynamic> body = {
        "card_users": selectedUuids,
        "card_type": cardType.trim().isNotEmpty ? cardType.trim() : 'new',
        "student_card": cardFor.contains('student_card') ? 1 : 0,
        "parent_card": cardFor.contains('parent_card') ? 1 : 0,
        "admit_card": cardFor.contains('admit_card') ? 1 : 0,
      };

      print("=== createOrder REQUEST ===");
      print("URL: $url");
      print("BODY: ${jsonEncode(body)}");

      var response = await _api.postRequest(body, url);

      if (response != null && response.statusCode == 403) {
        final String partnerUrl =
            '${Config.baseUrl}auth/partner/school/$schoolId/orders';
        response = await _api.postRequest(body, partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(
          createOrderLoading: false,
          createOrderError: 'Failed to create order',
        ));
        return;
      }

      final dynamic jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        emit(state.copyWith(
          createOrderLoading: false,
          createOrderSuccess: true,
          selectedStudentIds: {},
        ));
      } else {
        emit(state.copyWith(
          createOrderLoading: false,
          createOrderError: jsonResponse['message'] ?? 'Failed to create order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        createOrderLoading: false,
        createOrderError: e.toString(),
      ));
    }
  }

  Future<void> fetchCorrectionStudents({
    required String schoolId,
    bool isLoadMore = false,
    String search = '',
    String classFilter = '',
    List<String> classIds = const [],
    List<int> sectionIds = const [],
  }) async {
    if (isLoadMore &&
        (state.studentsLoading || !state.studentsHasMore)) {
      return;
    }

    final currentPage = isLoadMore ? state.studentsPage : 1;

    final effectiveClassFilter =
    classIds.isNotEmpty ? classIds.join(',') : classFilter;

    if (!isLoadMore) {
      emit(state.copyWith(
        studentsLoading: true,
        students: [],
        studentsPage: 1,
        studentsHasMore: true,
        clearStudentsError: true,
        selectedClassIds: classIds.isNotEmpty
            ? classIds
            : (classFilter.isNotEmpty
            ? classFilter.split(',')
            : state.selectedClassIds),
      ));
    }

    try {
      String url =
          '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists/students?page=$currentPage&per_page=50';

      if (search.isNotEmpty) url += '&search=$search';

      if (effectiveClassFilter.isNotEmpty) {
        url += '&class_filters=$effectiveClassFilter';
      }

      for (int i = 0; i < sectionIds.length; i++) {
        url += '&sectionsIds[$i]=${sectionIds[i]}';
      }

      var response = await _api.getRequest(url);

      if (response != null && response.statusCode == 403) {
        String partnerUrl =
            '${Config.baseUrl}auth/partner/school/$schoolId/orders/correction-lists/students?page=$currentPage&per_page=50';

        if (search.isNotEmpty) partnerUrl += '&search=$search';
        if (effectiveClassFilter.isNotEmpty) {
          partnerUrl += '&class_filters=$effectiveClassFilter';
        }
        for (int i = 0; i < sectionIds.length; i++) {
          partnerUrl += '&sectionsIds[$i]=${sectionIds[i]}';
        }

        response = await _api.getRequest(partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(
          studentsLoading: false,
          studentsError: 'Failed to load students',
        ));
        return;
      }

      final json = jsonDecode(response.body);

      if (json['success'] != true) {
        emit(state.copyWith(
          studentsLoading: false,
          studentsError: json['message'] ?? 'Something went wrong',
        ));
        return;
      }

      final data = json['data'] as Map<String, dynamic>?;

      final listPage =
      (data?['list'] ?? data?['students']) as Map<String, dynamic>?;

      final List rawList = listPage?['data'] ?? [];

      final int lastPage = listPage?['last_page'] ?? 1;
      final int respPage = listPage?['current_page'] ?? 1;

      final newItems = rawList
          .map(
            (e) => CorrectionStudentItem.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();

      final updated =
      isLoadMore ? [...state.students, ...newItems] : newItems;

      final int total = listPage?['total'] ??
          (isLoadMore ? state.studentsTotal : updated.length);

      emit(state.copyWith(
        studentsLoading: false,
        students: updated,
        studentsPage: respPage + 1,
        studentsHasMore: respPage < lastPage,
        studentsTotal: total,
      ));
    } catch (e) {
      emit(state.copyWith(
        studentsLoading: false,
        studentsError: e.toString(),
      ));
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
        url =
        '${Config.baseUrl}auth/partner/school/$schoolId/student-form-fields';
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
          .map(
            (e) => DownloadColumn(
          key: e['name'].toString(),
          label: e['label'].toString(),
        ),
      )
          .toList();

      emit(state.copyWith(
        columnsLoading: false,
        downloadColumns: columns,
      ));
    } catch (e) {
      emit(state.copyWith(columnsLoading: false));
    }
  }

  Future<Uint8List?> downloadCorrectionList({
    required String schoolId,
    required List<String> selected,
    required String listType,
  }) async {
    emit(state.copyWith(
      downloadLoading: true,
      clearDownloadError: true,
      clearDownloadUrl: true,
    ));

    try {
      String url =
          '${Config.baseUrl}auth/school/$schoolId/orders/correction-lists/download';

      final body = {
        'list_type': listType,
        'selected': selected,
      };

      var response = await _api.postRequest(body, url);

      if (response != null && response.statusCode == 403) {
        final partnerUrl =
            '${Config.baseUrl}auth/partner/school/$schoolId/orders/correction-lists/download';
        response = await _api.postRequest(body, partnerUrl);
      }

      if (response == null) {
        emit(state.copyWith(
          downloadLoading: false,
          downloadError: 'Failed to load PDF',
        ));
        return null;
      }

      final contentType =
          response.headers['content-type']?.toLowerCase() ?? '';

      if (contentType.contains('application/pdf') ||
          contentType.contains('application/octet-stream') ||
          (response.bodyBytes.isNotEmpty &&
              response.bodyBytes.first == 0x25)) {
        emit(state.copyWith(downloadLoading: false));
        return Uint8List.fromList(response.bodyBytes);
      }

      try {
        final json = jsonDecode(response.body);

        if (json['success'] == true) {
          final fileUrl =
              json['data']?['url'] ?? json['data']?['file_url'] ?? '';

          if (fileUrl.toString().isNotEmpty) {
            final res = await _api.getRequest(fileUrl);

            if (res != null && res.bodyBytes.isNotEmpty) {
              emit(state.copyWith(downloadLoading: false));
              return Uint8List.fromList(res.bodyBytes);
            }
          }
        } else {
          emit(state.copyWith(
            downloadLoading: false,
            downloadError: json['message'] ?? 'Download failed',
          ));
          return null;
        }
      } catch (e) {
        emit(state.copyWith(
          downloadLoading: false,
          downloadError: 'Invalid PDF format',
        ));
        return null;
      }

      emit(state.copyWith(
        downloadLoading: false,
        downloadError: 'Invalid PDF format',
      ));
      return null;
    } catch (e) {
      emit(state.copyWith(
        downloadLoading: false,
        downloadError: e.toString(),
      ));
      return null;
    }
  }

  Future<String?> savePdfFile(
      Uint8List pdfBytes,
      String fileName,
      ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}