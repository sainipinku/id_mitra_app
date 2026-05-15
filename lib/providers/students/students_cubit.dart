

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/local_db/student_local_ds/student_local_ds.dart';
import 'package:idmitra/models/LoginModel.dart';
import 'package:idmitra/models/LogoutModel.dart';
import 'package:idmitra/models/home/PartnerDashboardModel.dart';
import 'package:idmitra/models/home/UserDetailsModel.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/school/school_state.dart';
import 'package:idmitra/providers/students/students_state.dart';


class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit() : super(StudentsState());

  ApiManager apiManager = ApiManager();
  final localDS = StudentLocalDS();
  void applyFilters({
    String classId = "",
    List<int> sectionIds = const [],
    String gender = "",
    required String schoolId,
  }) {
    emit(state.copyWith(
      selectedClassId: classId,
      selectedSectionIds: sectionIds,
      selectedGender: gender,
      page: 1,
      hasMore: true,
    ));

    fetchStudents(
      classId: classId,
      sectionIds: sectionIds,
      gender: gender,
    );
  }
  Future<void> fetchStudents({
    String search = "",
    String gender = "",
    String classId = "",
    List<int> sectionIds = const [],
  }) async {

    emit(state.copyWith(loading: true));

    try {
      final localList = await localDS.getStudents(
        search: search,
        gender: gender,
        classId: classId,
        sectionIds: sectionIds,
      );

      print("FULL LOCAL DATA: ${localList.length}");

      emit(state.copyWith(
        loading: false,
        studentsList: localList,
        hasMore: false, // ❌ no pagination
        page: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
  Future<void> syncAllStudents({
    required String schoolId,
    String search = "",
    String gender = "",
    String classId = "",
    List<int> sectionIds = const [],
  }) async {
    /// 🔥 START LOADING
    emit(state.copyWith(isSyncing: true));
    await localDS.clearStudents(); // 🔥 MUST
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      String url =
          "${Config.baseUrl}auth/school/$schoolId"
          "?perPage=50"
          "&search=$search"
          "&page=$page"
          "&gender=$gender"
          "&class_filters=$classId";

      if (sectionIds.isNotEmpty) {
        url += "&" + sectionIds
            .asMap()
            .entries
            .map((e) => "sectionsIds[${e.key}]=${e.value}")
            .join("&");
      }

      try {
        final response = await apiManager.getRequest(url);
        final jsonData = jsonDecode(response.body);

        List list = jsonData["data"]?["data"] ?? [];
        int total = jsonData["data"]["total"] ?? 0;

        List<StudentDetailsData> newList =
        list.map((e) => StudentDetailsData.fromJson(e)).toList();

        await localDS.insertStudents(newList);

        int count = await localDS.getCount();

        hasMore = count < total;
        page++;
        print("Sync count: $count");
        print("Sync total: $total");
        print("Sync stopped: $page");
        /// 🔥 STOP LOADING


        if(page == 2){
          await fetchStudents();
        }
        emit(state.copyWith(isSyncing: false));
      } catch (e) {
        print("Sync stopped: $e");
        break;
      }
    }

    print(" FULL DATA SYNC DONE");
  }

  void prependStudent(StudentDetailsData student) {
    emit(state.copyWith(
      studentsList: [student, ...state.studentsList],
    ));
  }

  Future<bool> deleteStudent(String studentUuid, String schoolId) async {
    try {
      final result = await apiManager.deleteRequest(
        "${Config.baseUrl}${Routes.deleteStudent(schoolId, studentUuid)}",
      );
      if (result.statusCode == 200) {
        final updated = state.studentsList
            .where((s) => s.uuid != studentUuid)
            .toList();
        emit(state.copyWith(studentsList: updated));
        return true;
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
    return false;
  }

  Future<void> fetchExtraStudents({String schoolId = ''}) async {
    emit(state.copyWith(extraLoading: true));
    try {
      final response = await apiManager.getRequest(
        "${Config.baseUrl}auth/school/$schoolId?is_moved=1",
      );
      final jsonData = jsonDecode(response.body);
      List list = jsonData["data"]?["data"] ?? [];
      final newList = list.map((e) => StudentDetailsData.fromJson(e)).toList();
      emit(state.copyWith(extraLoading: false, extraStudentsList: newList));
    } catch (e) {
      emit(state.copyWith(extraLoading: false));
      debugPrint("Fetch extra students error: $e");
    }
  }

  Future<bool> moveStudentToExtra(String studentUuid, String schoolId) async {
    try {
      final response = await apiManager.postWithoutRequest(
        "${Config.baseUrl}${Routes.moveStudentToExtra(schoolId, studentUuid)}",
      );
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        return true;
      }
    } catch (e) {
      debugPrint("Move to extra error: $e");
    }
    return false;
  }

  Future<bool> toggleStudentStatus(String studentUuid, String schoolId, int currentStatus) async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = "${Config.baseUrl}${Routes.toggleStudentStatus(schoolId, studentUuid)}";
      final newStatusStr = currentStatus == 1 ? false : true;

      final result = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': newStatusStr}),
      );

      debugPrint('Student update status: ${result.statusCode} - ${result.body}');

      if (result.statusCode == 200 || result.statusCode == 201) {
        final json = jsonDecode(result.body);
        final newStatus = (json['data']['status'] as int?) ?? (currentStatus == 1 ? 0 : 1);
        final updated = state.studentsList.map((s) {
          if (s.uuid == studentUuid) return s.copyWith(status: newStatus);
          return s;
        }).toList();
        emit(state.copyWith(studentsList: updated));
        return true;
      }
    } catch (e) {
      debugPrint("Toggle status error: $e");
    }
    return false;
  }
}