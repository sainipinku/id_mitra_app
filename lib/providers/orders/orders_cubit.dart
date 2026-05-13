import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/providers/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  final ApiManager _api = ApiManager();

  static const _classOrder = [
    'pre nursery', 'prenursery', 'pre-nursery',
    'nursery',
    'prep', 'pre prep', 'preprep', 'pre-prep',
    'lkg', 'l.k.g', 'lower kg', 'lower kindergarten', 'l kg',
    'ukg', 'u.k.g', 'upper kg', 'upper kindergarten', 'u kg',
    'kg', 'k.g', 'kindergarten',
    '1', 'i', 'class 1', 'grade 1',
    '2', 'ii', 'class 2', 'grade 2',
    '3', 'iii', 'class 3', 'grade 3',
    '4', 'iv', 'class 4', 'grade 4',
    '5', 'v', 'class 5', 'grade 5',
    '6', 'vi', 'class 6', 'grade 6',
    '7', 'vii', 'class 7', 'grade 7',
    '8', 'viii', 'class 8', 'grade 8',
    '9', 'ix', 'class 9', 'grade 9',
    '10', 'x', 'class 10', 'grade 10',
    '11', 'xi', 'class 11', 'grade 11',
    '12', 'xii', 'class 12', 'grade 12',
  ];

  static int _classSortIndex(String name) {
    final lower = name.trim().toLowerCase();
    // Exact match first
    for (int i = 0; i < _classOrder.length; i++) {
      if (lower == _classOrder[i]) return i;
    }
    // Then starts-with match (e.g. "class 1 a" → "class 1")
    for (int i = 0; i < _classOrder.length; i++) {
      if (lower.startsWith(_classOrder[i])) return i;
    }
    return 999;
  }

  static List<OrderClass> _sortClasses(List<OrderClass> classes) {
    final sorted = [...classes];
    sorted.sort((a, b) {
      final aName = a.nameWithprefix ?? a.name;
      final bName = b.nameWithprefix ?? b.name;
      final ai = _classSortIndex(aName);
      final bi = _classSortIndex(bName);
      if (ai != bi) return ai.compareTo(bi);
      return aName.toLowerCase().compareTo(bName.toLowerCase());
    });
    return sorted;
  }


  Future<void> fetchSchoolClasses(String schoolId) async {
    if (schoolId.isEmpty) return;
    emit(state.copyWith(classesLoading: true));
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/students/form-data';
      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(classesLoading: false));
        return;
      }
      final json = jsonDecode(response.body);
      print('fetchSchoolClasses STATUS: ${response.statusCode}');
      print('fetchSchoolClasses BODY: ${response.body}');
      final data = json['data'] ?? json;
      final List rawClasses = data['classes'] ?? [];

      final List<OrderClass> classes = [];
      for (final e in rawClasses) {
        final int classId = e['id'] is int
            ? e['id'] as int
            : int.tryParse(e['id']?.toString() ?? '') ?? 0;
        final String name = e['name']?.toString() ?? '';
        final String? nameWithprefix = e['name_withprefix']?.toString() ??
            e['name_with_prefix']?.toString();

        // Try all possible section keys
        final List sections = e['sections'] as List? ??
            e['class_sections'] as List? ??
            e['classSections'] as List? ??
            [];

        print('CLASS: $classId | name: $name | nameWithprefix: $nameWithprefix | sections count: ${sections.length}');

        if (sections.isNotEmpty) {
          for (final sec in sections) {
            final rawId = sec['id'] ?? sec['section_id'] ?? sec['class_section_id'];
            final int? sectionId = rawId is int
                ? rawId
                : int.tryParse(rawId?.toString() ?? '');
            final String sectionName = (sec['name']?.toString().trim().isNotEmpty == true)
                ? sec['name'].toString().trim()
                : (sec['section_name']?.toString().trim() ??
                sec['title']?.toString().trim() ?? '');
            print('  SECTION: id=$sectionId name=$sectionName raw=$sec');
            classes.add(OrderClass(
              classId: classId,
              sectionId: sectionId,
              name: name,
              nameWithprefix: nameWithprefix,
              sectionName: sectionName,
            ));
          }
        } else {
          classes.add(OrderClass(
            classId: classId,
            sectionId: null,
            name: name,
            nameWithprefix: nameWithprefix,
          ));
        }
      }

      print('TOTAL OrderClass items: ${classes.length}');
      emit(state.copyWith(availableClasses: _sortClasses(classes), classesLoading: false));
    } catch (e) {
      print('fetchSchoolClasses error: $e');
      emit(state.copyWith(classesLoading: false));
    }
  }

  // ─── Fetch school-specific orders (auth/school/{id}/orders) ─────────────
  Future<void> fetchSchoolOrders({
    bool isLoadMore = false,
    String search = '',
    String status = '',
    String classFilter = '',
    String dateFrom = '',
    String dateTo = '',
    required String schoolId,
  }) async {
    if (isLoadMore && (state.isPaginationLoading || !state.hasMore)) return;

    final currentPage = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        isPaginationLoading: false,
        page: 1,
        ordersList: [],
        hasMore: true,
        clearError: true,
        schoolId: schoolId,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      String url = '${Config.baseUrl}auth/school/$schoolId/orders?page=$currentPage&per_page=20';
      if (search.isNotEmpty) url += '&search=$search';
      if (status.isNotEmpty) url += '&status=$status';
      if (classFilter.isNotEmpty) url += '&class_filters=$classFilter';
      if (dateFrom.isNotEmpty) url += '&start_date=$dateFrom';
      if (dateTo.isNotEmpty) url += '&end_date=$dateTo';
      print('fetchSchoolOrders URL: $url');

      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: 'Failed to load orders'));
        return;
      }

      final json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: 'Invalid response'));
        return;
      }

      final ordersData = data['orders'] as Map<String, dynamic>?;
      if (ordersData == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, ordersList: [], hasMore: false, total: 0));
        return;
      }

      final List rawList = ordersData['data'] ?? [];
      final int total = ordersData['total'] ?? 0;
      final int lastPage = ordersData['last_page'] ?? 1;
      final int respPage = ordersData['current_page'] ?? 1;

      final newOrders = rawList.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      final updatedList = isLoadMore ? [...state.ordersList, ...newOrders] : newOrders;

      // Extract classes_with_sections for dropdown (only on first page)
      List<SchoolOrderClass> classesWithSections = state.schoolClassesWithSections;
      if (!isLoadMore && data['classes_with_sections'] != null) {
        final List rawClasses = data['classes_with_sections'] as List;
        classesWithSections = rawClasses
            .map((e) => SchoolOrderClass(value: e['value'] ?? '', label: e['label'] ?? ''))
            .toList();
      }

      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
        ordersList: updatedList,
        page: respPage + 1,
        hasMore: respPage < lastPage,
        total: total,
        schoolClassesWithSections: classesWithSections,
      ));
    } catch (e) {
      print('fetchSchoolOrders error: $e');
      emit(state.copyWith(loading: false, isPaginationLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchOrders({
    bool isLoadMore = false,
    String search = '',
    String status = '',
    String classId = '',
    String dateFrom = '',
    String dateTo = '',
    String schoolId = '',
    bool isSchool = false,
  }) async {
    if (isLoadMore && (state.isPaginationLoading || !state.hasMore)) return;

    final currentPage = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        isPaginationLoading: false,
        page: 1,
        ordersList: [],
        hasMore: true,
        clearError: true,
        schoolId: schoolId,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      String url;
      if (schoolId.isNotEmpty) {
        url = '${Config.baseUrl}auth/partner/orders?page=$currentPage&per_page=20&school_id=$schoolId';
      } else {
        url = '${Config.baseUrl}auth/partner/orders?page=$currentPage&per_page=20';
      }
      if (status.isNotEmpty) url += '&status=$status';
      if (search.isNotEmpty) url += '&search=$search';
      if (dateFrom.isNotEmpty) url += '&date_from=$dateFrom';
      if (dateTo.isNotEmpty) url += '&date_to=$dateTo';
      // class_id filtered on frontend
      print('fetchOrders URL: $url');

      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: 'Failed to load orders'));
        return;
      }
      print('fetchOrders status: ${response.statusCode}, body length: ${response.body.length}');

      final json = jsonDecode(response.body);
      final data = (json['data'] as Map<String, dynamic>?);
      if (data == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: 'Invalid response format'));
        return;
      }

      List rawList = [];
      int total = 0;
      int lastPage = 1;
      int respPage = 1;

      if (data['orders'] is List) {
        rawList = data['orders'] as List;
        final pagination = data['pagination'] as Map<String, dynamic>?;
        total = pagination?['total'] ?? rawList.length;
        lastPage = pagination?['last_page'] ?? 1;
        respPage = pagination?['current_page'] ?? 1;
      } else if (data['orders'] is Map) {
        final ordersData = data['orders'] as Map<String, dynamic>;
        rawList = ordersData['data'] ?? [];
        total = ordersData['total'] ?? 0;
        lastPage = ordersData['last_page'] ?? 1;
        respPage = ordersData['current_page'] ?? 1;
      }

      final newOrders = rawList.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();

      List<OrderModel> filtered;
      if (classId.isNotEmpty) {
        final parts = classId.split('_');
        final filterClassId = parts[0];
        final filterSectionId = parts.length > 1 ? parts[1] : null;
        filtered = newOrders.where((o) {
          final matchClass = o.student?.classId?.toString() == filterClassId;
          if (!matchClass) return false;
          if (filterSectionId != null && filterSectionId.isNotEmpty) {
            return true;
          }
          return true;
        }).toList();
      } else {
        filtered = newOrders;
      }

      final updatedList = isLoadMore ? [...state.ordersList, ...filtered] : filtered;

      final hasMore = respPage < lastPage;

      if (classId.isNotEmpty && filtered.isEmpty && hasMore) {
        emit(state.copyWith(
          isPaginationLoading: false,
          loading: false,
          page: respPage + 1,
          hasMore: true,
          total: total,
          ordersList: isLoadMore ? state.ordersList : [],
        ));
        await fetchOrders(
          isLoadMore: true,
          search: search,
          status: status,
          classId: classId,
          dateFrom: dateFrom,
          dateTo: dateTo,
          schoolId: schoolId,
          isSchool: isSchool,
        );
        return;
      }

      List<OrderClass> classes = state.availableClasses;

      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
        ordersList: updatedList,
        page: respPage + 1,
        hasMore: respPage < lastPage,
        total: total,
        availableClasses: classes,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, isPaginationLoading: false, error: e.toString()));
    }
  }


  Future<bool> updateOrderStatus(String uuid, String newStatus, {String schoolId = '', bool isSchool = false}) async {
    try {
      final url = '${Config.baseUrl}auth/partner/orders/$uuid/status';
      print('updateOrderStatus URL: $url');
      print('Body: {status: $newStatus}');
      final response = await _api.patchRequestWithBody(url, {'status': newStatus});
      if (response == null) return false;
      final json = jsonDecode(response.body);
      print('updateOrderStatus response: ${response.body}');
      if (json['success'] == true) return true;
      final errors = json['errors'];
      if (errors != null) print('Validation errors: $errors');
      return false;
    } catch (e) {
      print('updateOrderStatus error: $e');
      return false;
    }
  }



  Future<void> fetchStaffOrdersTotal({required String schoolId}) async {
    if (schoolId.isEmpty) return;
    emit(state.copyWith(staffTotalLoading: true));
    try {
      final url = '${Config.baseUrl}auth/school/$schoolId/staff/orders?page=1&per_page=1';
      print('fetchStaffOrdersTotal URL: $url');
      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(staffTotalLoading: false));
        return;
      }
      print('fetchStaffOrdersTotal status: ${response.statusCode}, body: ${response.body}');
      final json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>?;
      int total = 0;
      if (data != null) {
        if (data['list'] is Map) {
          final listData = data['list'] as Map<String, dynamic>;
          total = listData['total'] ?? 0;
        }
        else if (data['orders'] is List) {
          final pagination = data['pagination'] as Map<String, dynamic>?;
          total = pagination?['total'] ?? (data['orders'] as List).length;
        }
        else if (data['orders'] is Map) {
          final ordersData = data['orders'] as Map<String, dynamic>;
          total = ordersData['total'] ?? 0;
        }
        else if (data['total'] != null) {
          total = data['total'] ?? 0;
        }
      }
      emit(state.copyWith(staffTotalLoading: false, staffTotal: total));
    } catch (e) {
      print('fetchStaffOrdersTotal error: $e');
      emit(state.copyWith(staffTotalLoading: false));
    }
  }
}
