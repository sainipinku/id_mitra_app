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

  // Stores manually uploaded photo URLs by staff UUID
  // Persists across list refreshes since server doesn't return uploaded URL correctly
  final Map<String, String> _uploadedPhotos = {};

  void updateStaffPhoto(String uuid, String photoUrl) {
    _uploadedPhotos[uuid] = photoUrl;
    final updated = state.list.map((s) {
      if (s.uuid != uuid) return s;
      return StaffListModel(
        id: s.id, uuid: s.uuid, name: s.name,
        designation: s.designation, department: s.department,
        email: s.email, phone: s.phone,
        whatsappPhone: s.whatsappPhone, address: s.address,
        profilePhotoUrl: photoUrl,
        roleName: s.roleName, status: s.status,
        assignedClasses: s.assignedClasses,
      );
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
        final photoOverrides = _uploadedPhotos;
        final fixedItems = newItems.map((s) {
          final overrideUrl = photoOverrides[s.uuid];
          if (overrideUrl != null) {
            return StaffListModel(
              id: s.id, uuid: s.uuid, name: s.name,
              designation: s.designation, department: s.department,
              email: s.email, phone: s.phone,
              whatsappPhone: s.whatsappPhone, address: s.address,
              profilePhotoUrl: overrideUrl,
              roleName: s.roleName, status: s.status,
              assignedClasses: s.assignedClasses,
            );
          }
          return s;
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

  Future<bool> deleteStaff({required String schoolId, required String uuid}) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.deleteStaff(schoolId, uuid)}';
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final updated = state.list.where((s) => s.uuid != uuid).toList();
        emit(state.copyWith(list: updated, total: state.total - 1));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changeStaffPassword({
    required String schoolId,
    required String uuid,
    required String password,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.changeStaffPassword(schoolId, uuid)}';
      final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({'password': password, 'password_confirmation': password}),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('changeStaffPassword status: ${response.statusCode}');
      print('changeStaffPassword body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('changeStaffPassword error: $e');
      return false;
    }
  }

  Future<bool> toggleStaffStatus({
    required String schoolId,
    required String uuid,
    required int currentStatus,
  }) async {
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
      print('Update status body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final newStatusInt = currentStatus == 1 ? 0 : 1;
        final updated = state.list.map((s) {
          if (s.uuid == uuid) {
            return StaffListModel(
              id: s.id,
              uuid: s.uuid,
              name: s.name,
              designation: s.designation,
              department: s.department,
              email: s.email,
              phone: s.phone,
              whatsappPhone: s.whatsappPhone,
              address: s.address,
              profilePhotoUrl: s.profilePhotoUrl,
              roleName: s.roleName,
              status: newStatusInt,
              assignedClasses: s.assignedClasses,
            );
          }
          return s;
        }).toList();
        emit(state.copyWith(list: updated));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }


  Future<List<Map<String, dynamic>>> fetchAssignedClasses({
    required String schoolId,
    required String uuid,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.staffAssignedClasses(schoolId, uuid)}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      print('fetchAssignedClasses status: ${response.statusCode}');
      print('fetchAssignedClasses body: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final rawData = json['data']?['assigned_classes'];
        List<Map<String, dynamic>> result = [];
        if (rawData is Map) {
          rawData.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['assigned_uuid'] = key; // store map key as uuid for delete
            result.add(item);
          });
        } else if (rawData is List) {
          result = rawData.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        return result;
      }
    } catch (e) {
      print('fetchAssignedClasses error: $e');
    }
    return [];
  }

  Future<bool> assignClass({
    required String schoolId,
    required String uuid,
    required int classId,
    required List<int> sectionIds,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.staffAssignClass(schoolId, uuid)}';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'class': classId, 'section': sectionIds}),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('assignClass status: ${response.statusCode}');
      print('assignClass body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('assignClass error: $e');
      return false;
    }
  }

  Future<bool> removeAssignedClass({
    required String schoolId,
    required String assignedClassUuid,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.staffRemoveAssignedClass(schoolId, assignedClassUuid)}';
      print('removeAssignedClass URL: $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      print('removeAssignedClass status: ${response.statusCode}');
      print('removeAssignedClass body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('removeAssignedClass error: $e');
      return false;
    }
  }

  Future<String?> uploadStaffSignature({
    required String schoolId,
    required String uuid,
    required String imagePath,
  }) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}${Routes.uploadStaffSignature(schoolId, uuid)}';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('signature', imagePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('uploadStaffSignature status: ${response.statusCode}');
      print('uploadStaffSignature body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['data']?['signature_url'] as String?;
      }
    } catch (e) {
      print('uploadStaffSignature error: $e');
    }
    return null;
  }
}
