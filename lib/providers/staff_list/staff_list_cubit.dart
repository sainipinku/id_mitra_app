import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/models/staff/StaffListModel.dart';

class StaffListState {
  final bool loading;
  final bool paginationLoading;
  final List<StaffListModel> list;
  final int page;
  final bool hasMore;
  final int total;
  final String? error;

  const StaffListState({
    this.loading = false,
    this.paginationLoading = false,
    this.list = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,
  });

  StaffListState copyWith({
    bool? loading,
    bool? paginationLoading,
    List<StaffListModel>? list,
    int? page,
    bool? hasMore,
    int? total,
    String? error,
  }) =>
      StaffListState(
        loading: loading ?? this.loading,
        paginationLoading: paginationLoading ?? this.paginationLoading,
        list: list ?? this.list,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        total: total ?? this.total,
        error: error,
      );
}

class StaffListCubit extends Cubit<StaffListState> {
  StaffListCubit() : super(const StaffListState());

  Future<void> fetchStaff({
    required String schoolId,
    String search = '',
    bool isLoadMore = false,
  }) async {
    if (state.paginationLoading) return;
    if (isLoadMore && !state.hasMore) return;

    final page = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(loading: true, error: null, list: [], page: 1, hasMore: true));
    } else {
      emit(state.copyWith(paginationLoading: true));
    }

    try {
      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';
      final url = '${Config.baseUrl}${Routes.getStaffList(schoolId, page: page, search: search, isPartner: isPartner)}';
      print('Staff list URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      print('Staff list status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final listData = json['data']?['list'] ?? {};
        final List raw = listData['data'] ?? [];
        final int total = listData['total'] ?? 0;

        final newItems = raw
            .map((e) => StaffListModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final updated = isLoadMore ? [...state.list, ...newItems] : newItems;

        emit(state.copyWith(
          loading: false,
          paginationLoading: false,
          list: updated,
          page: page + 1,
          hasMore: updated.length < total,
          total: total,
        ));
      } else {
        String errorMsg;
        try {
          final json = jsonDecode(response.body);
          errorMsg = json['message'] ?? json['error'] ?? 'Something went wrong';
        } catch (_) {
          if (response.statusCode == 403) {
            errorMsg = 'Permission Denied';
          } else if (response.statusCode == 401) {
            errorMsg = 'Unauthorized. Please login again.';
          } else {
            errorMsg = 'Failed to load staff (${response.statusCode})';
          }
        }
        emit(state.copyWith(
          loading: false,
          paginationLoading: false,
          error: errorMsg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        paginationLoading: false,
        error: e.toString(),
      ));
    }
  }

  void prependStaff(StaffListModel staff) {
    emit(state.copyWith(list: [staff, ...state.list], total: state.total + 1));
  }
}
