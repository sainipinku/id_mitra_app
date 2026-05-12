import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/models/orders/OrderModel.dart';

import '../../screens/orders/order_staff_page.dart';


class StaffListState {
  final bool loading;
  final bool paginationLoading;
  final List<StaffListModel> list;
  final int page;
  final bool hasMore;
  final int total;
  final String? error;

  final List<OrderStaffItem> orders;
  final bool ordersLoading;
  final bool ordersPaginationLoading;
  final bool ordersHasMore;
  final int ordersPage;
  final int ordersTotal;
  final String? ordersError;
  final String ordersSelectedStatus;
  final String ordersDateFrom;
  final String ordersDateTo;
  final String ordersSearch;

  final Map<String, bool> orderUpdatingMap;
  final Map<String, String> orderStatusMap;

  final Map<String, bool> photoUploadingMap;

  final bool signatureUploading;
  final String? signatureUploadError;
  final String? signatureUploadSuccess;

  final bool deleting;

  final bool togglingStatus;

  final bool changingPassword;

  final bool assigningClass;
  final bool removingClass;

  final List<Map<String, dynamic>> assignedClasses;
  final bool assignedClassesLoading;

  const StaffListState({
    this.loading = false,
    this.paginationLoading = false,
    this.list = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,

    this.orders = const [],
    this.ordersLoading = false,
    this.ordersPaginationLoading = false,
    this.ordersHasMore = true,
    this.ordersPage = 1,
    this.ordersTotal = 0,
    this.ordersError,
    this.ordersSelectedStatus = '',
    this.ordersDateFrom = '',
    this.ordersDateTo = '',
    this.ordersSearch = '',

    this.orderUpdatingMap = const {},
    this.orderStatusMap = const {},

    this.photoUploadingMap = const {},

    this.signatureUploading = false,
    this.signatureUploadError,
    this.signatureUploadSuccess,

    this.deleting = false,
    this.togglingStatus = false,
    this.changingPassword = false,
    this.assigningClass = false,
    this.removingClass = false,

    this.assignedClasses = const [],
    this.assignedClassesLoading = false,
  });

  StaffListState copyWith({
    bool? loading,
    bool? paginationLoading,
    List<StaffListModel>? list,
    int? page,
    bool? hasMore,
    int? total,
    String? error,

    List<OrderStaffItem>? orders,
    bool? ordersLoading,
    bool? ordersPaginationLoading,
    bool? ordersHasMore,
    int? ordersPage,
    int? ordersTotal,
    String? ordersError,
    String? ordersSelectedStatus,
    String? ordersDateFrom,
    String? ordersDateTo,
    String? ordersSearch,

    Map<String, bool>? orderUpdatingMap,
    Map<String, String>? orderStatusMap,

    Map<String, bool>? photoUploadingMap,

    bool? signatureUploading,
    String? signatureUploadError,
    String? signatureUploadSuccess,

    bool? deleting,
    bool? togglingStatus,
    bool? changingPassword,
    bool? assigningClass,
    bool? removingClass,

    List<Map<String, dynamic>>? assignedClasses,
    bool? assignedClassesLoading,

    bool clearError = false,
    bool clearOrdersError = false,
    bool clearSignatureMessages = false,
  }) =>
      StaffListState(
        loading: loading ?? this.loading,
        paginationLoading: paginationLoading ?? this.paginationLoading,
        list: list ?? this.list,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        total: total ?? this.total,
        error: clearError ? null : (error ?? this.error),

        orders: orders ?? this.orders,
        ordersLoading: ordersLoading ?? this.ordersLoading,
        ordersPaginationLoading: ordersPaginationLoading ?? this.ordersPaginationLoading,
        ordersHasMore: ordersHasMore ?? this.ordersHasMore,
        ordersPage: ordersPage ?? this.ordersPage,
        ordersTotal: ordersTotal ?? this.ordersTotal,
        ordersError: clearOrdersError ? null : (ordersError ?? this.ordersError),
        ordersSelectedStatus: ordersSelectedStatus ?? this.ordersSelectedStatus,
        ordersDateFrom: ordersDateFrom ?? this.ordersDateFrom,
        ordersDateTo: ordersDateTo ?? this.ordersDateTo,
        ordersSearch: ordersSearch ?? this.ordersSearch,

        orderUpdatingMap: orderUpdatingMap ?? this.orderUpdatingMap,
        orderStatusMap: orderStatusMap ?? this.orderStatusMap,

        photoUploadingMap: photoUploadingMap ?? this.photoUploadingMap,

        signatureUploading: signatureUploading ?? this.signatureUploading,
        signatureUploadError: clearSignatureMessages ? null : (signatureUploadError ?? this.signatureUploadError),
        signatureUploadSuccess: clearSignatureMessages ? null : (signatureUploadSuccess ?? this.signatureUploadSuccess),

        deleting: deleting ?? this.deleting,
        togglingStatus: togglingStatus ?? this.togglingStatus,
        changingPassword: changingPassword ?? this.changingPassword,
        assigningClass: assigningClass ?? this.assigningClass,
        removingClass: removingClass ?? this.removingClass,

        assignedClasses: assignedClasses ?? this.assignedClasses,
        assignedClassesLoading: assignedClassesLoading ?? this.assignedClassesLoading,
      );


  bool isPhotoUploading(String uuid) => photoUploadingMap[uuid] ?? false;
  bool isOrderUpdating(String uuid) => orderUpdatingMap[uuid] ?? false;
  String orderStatus(String uuid, String fallback) =>
      orderStatusMap[uuid] ?? fallback;
}


class StaffListCubit extends Cubit<StaffListState> {
  StaffListCubit() : super(const StaffListState());

  final Map<String, String> _uploadedPhotos = {};

  void updateStaffPhoto(String uuid, String photoUrl) {
    _uploadedPhotos[uuid] = photoUrl;
    final updated = state.list.map((s) {
      if (s.uuid != uuid) return s;
      return s.copyWith(profilePhotoUrl: photoUrl);
    }).toList();
    emit(state.copyWith(list: updated));
  }

  Future<void> fetchStaff({
    required String schoolId,
    String search = '',
    bool isLoadMore = false,
  }) async {
    if (state.paginationLoading) return;
    if (isLoadMore && !state.hasMore) return;

    final page = isLoadMore ? state.page : 1;

    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        clearError: true,
        list: [],
        page: 1,
        hasMore: true,
      ));
    } else {
      emit(state.copyWith(paginationLoading: true));
    }

    try {
      final token = await UserSecureStorage.fetchToken();
      final role = await UserSecureStorage.fetchRole();
      final isPartner = role == 'partner';
      final url =
          '${Config.baseUrl}${Routes.getStaffList(schoolId, page: page, search: search, isPartner: isPartner)}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final listData = json['data']?['list'] ?? {};
        final List raw = listData['data'] ?? [];
        final int total = listData['total'] ?? 0;

        final newItems = raw
            .map((e) => StaffListModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final fixedItems = newItems.map((s) {
          final overrideUrl = _uploadedPhotos[s.uuid];
          return overrideUrl != null ? s.copyWith(profilePhotoUrl: overrideUrl) : s;
        }).toList();

        final updated = isLoadMore ? [...state.list, ...fixedItems] : fixedItems;

        emit(state.copyWith(
          loading: false,
          paginationLoading: false,
          list: updated,
          page: page + 1,
          hasMore: updated.length < total,
          total: total,
        ));
      } else {
        emit(state.copyWith(
          loading: false,
          paginationLoading: false,
          error: _parseErrorMessage(response),
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
    emit(state.copyWith(
      list: [staff, ...state.list],
      total: state.total + 1,
    ));
  }


  Future<bool> deleteStaff({
    required String schoolId,
    required String uuid,
  }) async {
    emit(state.copyWith(deleting: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.deleteStaff(schoolId, uuid)}';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final updated = state.list.where((s) => s.uuid != uuid).toList();
        emit(state.copyWith(
          deleting: false,
          list: updated,
          total: state.total - 1,
        ));
        return true;
      }
      emit(state.copyWith(deleting: false));
      return false;
    } catch (_) {
      emit(state.copyWith(deleting: false));
      return false;
    }
  }


  Future<bool> changeStaffPassword({
    required String schoolId,
    required String uuid,
    required String password,
  }) async {
    emit(state.copyWith(changingPassword: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.changeStaffPassword(schoolId, uuid)}';
      final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({
          'password': password,
          'password_confirmation': password,
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final success =
          response.statusCode == 200 || response.statusCode == 201;
      emit(state.copyWith(changingPassword: false));
      return success;
    } catch (_) {
      emit(state.copyWith(changingPassword: false));
      return false;
    }
  }


  Future<bool> toggleStaffStatus({
    required String schoolId,
    required String uuid,
    required int currentStatus,
  }) async {
    emit(state.copyWith(togglingStatus: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.toggleStaffStatus(schoolId, uuid)}';
      final newStatus = currentStatus == 1 ? false : true;
      final response = await http.patch(
        Uri.parse(url),
        body: jsonEncode({'status': newStatus}),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newStatusInt = currentStatus == 1 ? 0 : 1;
        final updated = state.list.map((s) {
          if (s.uuid == uuid) return s.copyWith(status: newStatusInt);
          return s;
        }).toList();
        emit(state.copyWith(togglingStatus: false, list: updated));
        return true;
      }
      emit(state.copyWith(togglingStatus: false));
      return false;
    } catch (_) {
      emit(state.copyWith(togglingStatus: false));
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssignedClasses({
    required String schoolId,
    required String uuid,
  }) async {
    emit(state.copyWith(assignedClassesLoading: true, assignedClasses: []));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}${Routes.staffAssignedClasses(schoolId, uuid)}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final rawData = json['data']?['assigned_classes'];
        List<Map<String, dynamic>> result = [];
        if (rawData is Map) {
          rawData.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['assigned_uuid'] = key;
            result.add(item);
          });
        } else if (rawData is List) {
          result = rawData.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        emit(state.copyWith(
          assignedClassesLoading: false,
          assignedClasses: result,
        ));
        return result;
      }
    } catch (e) {
      // ignore
    }
    emit(state.copyWith(assignedClassesLoading: false, assignedClasses: []));
    return [];
  }

  Future<bool> assignClass({
    required String schoolId,
    required String uuid,
    required int classId,
    required List<int> sectionIds,
  }) async {
    emit(state.copyWith(assigningClass: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}${Routes.staffAssignClass(schoolId, uuid)}';
      final body = jsonEncode({'class': classId, 'section': sectionIds});
      print('AssignClass URL: $url');
      print('AssignClass Body: $body');
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('AssignClass Status: ${response.statusCode}');
      print('AssignClass Response: ${response.body}');
      final success =
          response.statusCode == 200 || response.statusCode == 201;
      emit(state.copyWith(assigningClass: false));
      return success;
    } catch (e) {
      print('AssignClass Error: $e');
      emit(state.copyWith(assigningClass: false));
      return false;
    }
  }

  Future<bool> removeAssignedClass({
    required String schoolId,
    required String assignedClassUuid,
  }) async {
    emit(state.copyWith(removingClass: true));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}${Routes.staffRemoveAssignedClass(schoolId, assignedClassUuid)}';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      final success =
          response.statusCode == 200 || response.statusCode == 201;
      emit(state.copyWith(removingClass: false));
      return success;
    } catch (_) {
      emit(state.copyWith(removingClass: false));
      return false;
    }
  }


  Future<String?> uploadStaffPhoto({
    required String schoolId,
    required String uuid,
    required String imagePath,
  }) async {
    final uploadingMap = Map<String, bool>.from(state.photoUploadingMap);
    uploadingMap[uuid] = true;
    emit(state.copyWith(photoUploadingMap: uploadingMap));

    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}${Routes.uploadStaffPhoto(schoolId, uuid)}';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        String? newUrl = json['data']?['profile_photo_url'] as String?;
        if (newUrl != null) {
          final regex = RegExp(r'https?://');
          final matches = regex.allMatches(newUrl).toList();
          if (matches.length > 1) newUrl = newUrl.substring(matches.last.start);
          newUrl = newUrl
              .replaceAll('http://localhost:8000', 'https://idmitra.com')
              .replaceAll('http://localhost', 'https://idmitra.com');
        }
        if (newUrl != null) {
          updateStaffPhoto(uuid, newUrl);
        }
        final doneMap = Map<String, bool>.from(state.photoUploadingMap);
        doneMap.remove(uuid);
        emit(state.copyWith(photoUploadingMap: doneMap));
        return newUrl;
      }
    } catch (_) {
    }

    final doneMap = Map<String, bool>.from(state.photoUploadingMap);
    doneMap.remove(uuid);
    emit(state.copyWith(photoUploadingMap: doneMap));
    return null;
  }


  Future<String?> uploadStaffSignature({
    required String schoolId,
    required String uuid,
    required String imagePath,
  }) async {
    emit(state.copyWith(
      signatureUploading: true,
      clearSignatureMessages: true,
    ));
    try {
      final token = await UserSecureStorage.fetchToken();
      final url =
          '${Config.baseUrl}${Routes.uploadStaffSignature(schoolId, uuid)}';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files
          .add(await http.MultipartFile.fromPath('signature', imagePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final signatureUrl = json['data']?['signature_url'] as String?;
        emit(state.copyWith(
          signatureUploading: false,
          signatureUploadSuccess: 'Signature uploaded successfully',
        ));
        return signatureUrl;
      }
    } catch (_) {
    }
    emit(state.copyWith(
      signatureUploading: false,
      signatureUploadError: 'Failed to upload signature',
    ));
    return null;
  }

  void clearSignatureMessages() {
    emit(state.copyWith(clearSignatureMessages: true));
  }


  Future<void> fetchStaffOrders({
    required String schoolId,
    bool reset = false,
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final effectiveSearch = search ?? state.ordersSearch;
    final effectiveStatus = status ?? state.ordersSelectedStatus;
    final effectiveDateFrom = dateFrom ?? state.ordersDateFrom;
    final effectiveDateTo = dateTo ?? state.ordersDateTo;

    if (!reset && (state.ordersLoading || state.ordersPaginationLoading)) return;
    if (!reset && !state.ordersHasMore) return;

    final currentPage = reset ? 1 : state.ordersPage;

    if (reset || state.orders.isEmpty) {
      emit(state.copyWith(
        ordersLoading: true,
        clearOrdersError: true,
        orders: reset ? [] : state.orders,
        ordersPage: 1,
        ordersHasMore: true,
        ordersSearch: effectiveSearch,
        ordersSelectedStatus: effectiveStatus,
        ordersDateFrom: effectiveDateFrom,
        ordersDateTo: effectiveDateTo,
      ));
    } else {
      emit(state.copyWith(ordersPaginationLoading: true));
    }

    try {
      String url =
          '${Config.baseUrl}auth/school/$schoolId/staff/orders?page=$currentPage';
      if (effectiveStatus.isNotEmpty) url += '&status=$effectiveStatus';
      if (effectiveSearch.isNotEmpty) url += '&search=$effectiveSearch';
      if (effectiveDateFrom.isNotEmpty) url += '&start_date=$effectiveDateFrom';
      if (effectiveDateTo.isNotEmpty) url += '&end_date=$effectiveDateTo';

      final response = await ApiManager().getRequest(url);
      if (response == null) {
        emit(state.copyWith(
          ordersLoading: false,
          ordersPaginationLoading: false,
          ordersError: 'Failed to load staff orders',
        ));
        return;
      }

      final json = jsonDecode(response.body);
      final isSuccess =
          json['status'] == true || json['success'] == true;
      if (!isSuccess) {
        emit(state.copyWith(
          ordersLoading: false,
          ordersPaginationLoading: false,
          ordersError: json['message'] ?? 'Failed to load staff orders',
        ));
        return;
      }

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        emit(state.copyWith(
          ordersLoading: false,
          ordersPaginationLoading: false,
          ordersError: 'Invalid response format',
        ));
        return;
      }

      List rawList = [];
      int total = 0, lastPage = 1, respPage = 1;

      if (data.containsKey('list') && data['list'] is Map) {
        final listData = data['list'] as Map<String, dynamic>;
        rawList = listData['data'] ?? [];
        total = listData['total'] ?? 0;
        lastPage = listData['last_page'] ?? 1;
        respPage = listData['current_page'] ?? 1;
      } else if (data.containsKey('orders')) {
        final ordersData = data['orders'];
        if (ordersData is List) {
          rawList = ordersData;
          total = rawList.length;
        } else if (ordersData is Map) {
          rawList = ordersData['data'] ?? [];
          total = ordersData['total'] ?? 0;
          lastPage = ordersData['last_page'] ?? 1;
          respPage = ordersData['current_page'] ?? 1;
        }
      } else if (data.containsKey('data') && data['data'] is List) {
        rawList = data['data'] as List;
        total = data['total'] ?? rawList.length;
        lastPage = data['last_page'] ?? 1;
        respPage = data['current_page'] ?? 1;
      }

      final newOrders = rawList
          .map((e) => OrderStaffItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final statusMap = Map<String, String>.from(state.orderStatusMap);

      final mergedOrders =
      reset ? newOrders : [...state.orders, ...newOrders];

      emit(state.copyWith(
        ordersLoading: false,
        ordersPaginationLoading: false,
        ordersTotal: total,
        ordersPage: respPage + 1,
        ordersHasMore: respPage < lastPage,
        orders: mergedOrders,
        orderStatusMap: statusMap,
        ordersSearch: effectiveSearch,
        ordersSelectedStatus: effectiveStatus,
        ordersDateFrom: effectiveDateFrom,
        ordersDateTo: effectiveDateTo,
      ));
    } catch (e) {
      emit(state.copyWith(
        ordersLoading: false,
        ordersPaginationLoading: false,
        ordersError: e.toString(),
      ));
    }
  }

  void setOrdersFilter({
    required String schoolId,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? search,
  }) {
    fetchStaffOrders(
      schoolId: schoolId,
      reset: true,
      status: status ?? state.ordersSelectedStatus,
      dateFrom: dateFrom ?? state.ordersDateFrom,
      dateTo: dateTo ?? state.ordersDateTo,
      search: search ?? state.ordersSearch,
    );
  }

  void clearOrdersFilters(String schoolId) {
    fetchStaffOrders(
      schoolId: schoolId,
      reset: true,
      status: '',
      dateFrom: '',
      dateTo: '',
      search: '',
    );
  }

  Future<bool> updateOrderStatus({
    required String orderUuid,
    required String newStatus,
  }) async {
    // Mark as updating
    final updatingMap = Map<String, bool>.from(state.orderUpdatingMap);
    updatingMap[orderUuid] = true;
    emit(state.copyWith(orderUpdatingMap: updatingMap));

    try {
      final api = ApiManager();
      final url =
          '${Config.baseUrl}auth/partner/orders/$orderUuid/status';
      final response =
      await api.patchRequestWithBody(url, {'status': newStatus});

      bool success = false;
      if (response != null) {
        final json = jsonDecode(response.body);
        success = json['success'] == true;
      }

      if (success) {
        final updatedOrders = state.orders.map((o) {
          if (o.uuid == orderUuid) {
            return o;
          }
          return o;
        }).toList();

        final statusMap = Map<String, String>.from(state.orderStatusMap);
        statusMap[orderUuid] = newStatus;

        final doneUpdatingMap = Map<String, bool>.from(state.orderUpdatingMap);
        doneUpdatingMap.remove(orderUuid);

        emit(state.copyWith(
          orderUpdatingMap: doneUpdatingMap,
          orderStatusMap: statusMap,
          orders: updatedOrders,
        ));
        return true;
      }

      final doneUpdatingMap = Map<String, bool>.from(state.orderUpdatingMap);
      doneUpdatingMap.remove(orderUuid);
      emit(state.copyWith(orderUpdatingMap: doneUpdatingMap));
      return false;
    } catch (_) {
      final doneUpdatingMap = Map<String, bool>.from(state.orderUpdatingMap);
      doneUpdatingMap.remove(orderUuid);
      emit(state.copyWith(orderUpdatingMap: doneUpdatingMap));
      return false;
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Something went wrong';
    } catch (_) {
      switch (response.statusCode) {
        case 403:
          return 'Permission Denied';
        case 401:
          return 'Unauthorized. Please login again.';
        default:
          return 'Failed to load staff (${response.statusCode})';
      }
    }
  }
}