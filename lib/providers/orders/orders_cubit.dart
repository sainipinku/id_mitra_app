import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/providers/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  final ApiManager _api = ApiManager();

  // ─── Fetch school classes ─────────────────────────────────────────────────
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
      final data = json['data'] ?? json;
      final List rawClasses = data['classes'] ?? [];
      print('fetchSchoolClasses classes count: ${rawClasses.length}');
      final classes = rawClasses
          .map((e) => OrderClass(e['id'] as int, e['name_withprefix'] ?? e['name'] ?? ''))
          .toList();
      emit(state.copyWith(availableClasses: classes, classesLoading: false));
    } catch (e) {
      print('fetchSchoolClasses error: $e');
      emit(state.copyWith(classesLoading: false));
    }
  }

  // ─── Fetch orders list ────────────────────────────────────────────────────
  Future<void> fetchOrders({
    bool isLoadMore = false,
    String search = '',
    String status = '',
    String classId = '',
    String dateFrom = '',
    String dateTo = '',
    String schoolId = '',
  }) async {
    if (state.isPaginationLoading || (!state.hasMore && isLoadMore)) return;

    final currentPage = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        page: 1,
        ordersList: [],
        hasMore: true,
        error: null,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      var url = '${Config.baseUrl}auth/partner/orders?page=$currentPage&per_page=20';
      if (schoolId.isNotEmpty) url += '&school_id=$schoolId';
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
      final data = json['data'] as Map<String, dynamic>;

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

      // Frontend class filter — backend does not support class_id param
      final filtered = classId.isNotEmpty
          ? newOrders.where((o) => o.student?.classId?.toString() == classId).toList()
          : newOrders;

      final updatedList = isLoadMore ? [...state.ordersList, ...filtered] : filtered;

      final hasMore = respPage < lastPage;

      // If class filter active and no results on this page but more pages exist, auto-load next
      if (classId.isNotEmpty && filtered.isEmpty && hasMore) {
        emit(state.copyWith(
          isPaginationLoading: false,
          loading: false,
          page: respPage + 1,
          hasMore: hasMore,
          total: total,
        ));
        fetchOrders(
          isLoadMore: true,
          search: search,
          status: status,
          classId: classId,
          dateFrom: dateFrom,
          dateTo: dateTo,
          schoolId: schoolId,
        );
        return;
      }

      // Extract unique classes from orders (only on first page load)
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

  // ─── Update order status ──────────────────────────────────────────────────
  Future<bool> updateOrderStatus(String uuid, String newStatus) async {
    try {
      final url = Config.baseUrl + Routes.updateOrderStatus(uuid);
      final response = await _api.patchRequestWithBody(url, {'status': newStatus});
      if (response == null) return false;
      final json = jsonDecode(response.body);
      print('updateOrderStatus response: ${response.body}');
      if (json['success'] == true) return true;
      // show validation errors if any
      final errors = json['errors'];
      if (errors != null) print('Validation errors: $errors');
      return false;
    } catch (e) {
      print('updateOrderStatus error: $e');
      return false;
    }
  }



  // ─── Fetch staff orders total ─────────────────────────────────────────────
  Future<void> fetchStaffOrdersTotal() async {
    emit(state.copyWith(staffTotalLoading: true));
    try {
      final url = '${Config.baseUrl}auth/partner/orders?page=1&per_page=1';
      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(staffTotalLoading: false));
        return;
      }
      final json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>?;
      int total = 0;
      if (data != null) {
        if (data['orders'] is List) {
          final pagination = data['pagination'] as Map<String, dynamic>?;
          total = pagination?['total'] ?? 0;
        } else if (data['orders'] is Map) {
          final ordersData = data['orders'] as Map<String, dynamic>;
          total = ordersData['total'] ?? 0;
        }
      }
      emit(state.copyWith(staffTotalLoading: false, staffTotal: total));
    } catch (_) {
      emit(state.copyWith(staffTotalLoading: false));
    }
  }
}
