import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/providers/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  final ApiManager _api = ApiManager();

  // ─── Fetch orders list ────────────────────────────────────────────────────
  Future<void> fetchOrders({
    bool isLoadMore = false,
    String search = '',
    String status = '',
    String classId = '',
    String dateFrom = '',
    String dateTo = '',
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
      var url = '${Config.baseUrl}auth/partner/orders/dashboard/list?page=$currentPage&per_page=20';
      if (status.isNotEmpty) url += '&status=$status';
      if (search.isNotEmpty) url += '&search=$search';
      if (dateFrom.isNotEmpty) url += '&date_from=$dateFrom';
      if (dateTo.isNotEmpty) url += '&date_to=$dateTo';
      if (classId.isNotEmpty) url += '&class_id=$classId';

      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: 'Failed to load orders'));
        return;
      }

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
      final updatedList = isLoadMore ? [...state.ordersList, ...newOrders] : newOrders;

      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
        ordersList: updatedList,
        page: respPage + 1,
        hasMore: respPage < lastPage,
        total: total,
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
      return json['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ─── Fetch statistics ─────────────────────────────────────────────────────
  Future<void> fetchStatistics() async {
    emit(state.copyWith(statsLoading: true));
    try {
      final url = Config.baseUrl + Routes.getOrderStatistics();
      final response = await _api.getRequest(url);
      if (response == null) {
        emit(state.copyWith(statsLoading: false));
        return;
      }
      final json = jsonDecode(response.body);
      final overview = json['data']?['overview'] as Map<String, dynamic>?;
      if (overview != null) {
        emit(state.copyWith(
          statsLoading: false,
          statistics: OrderStatistics.fromJson(overview),
        ));
      } else {
        emit(state.copyWith(statsLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(statsLoading: false));
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
