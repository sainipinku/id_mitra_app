

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

  Future<void> fetchStudents({
    bool isLoadMore = false,
    String search = "",
    String schoolId = "",
    String gender = "",
    String classId = "",
  }) async {

    // 🔴 Prevent multiple calls
    if (state.isPaginationLoading || (!state.hasMore && isLoadMore)) return;

    int currentPage = isLoadMore ? state.page : 1;

    // 🔥 RESET LIST ON SEARCH
    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        page: 1,
        studentsList: [],
        hasMore: true,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }


    final response = await apiManager.getRequest(
      "${Config.baseUrl}auth/school/$schoolId?search=$search&page=$currentPage&gender=$gender&class_filters=$classId",
    );

    final jsonData = jsonDecode(response.body);

    List list = jsonData["data"]?["data"] ?? [];

    List<StudentDetailsData> newList =
    list.map((e) => StudentDetailsData.fromJson(e)).toList();

    final total = jsonData["data"]["total"] ?? 0;

    List<StudentDetailsData> updatedList = isLoadMore
        ? [...state.studentsList, ...newList]
        : newList;

    bool hasMore = updatedList.length < total;

    emit(state.copyWith(
      loading: false,
      isPaginationLoading: false,
      studentsList: updatedList,
      page: currentPage + 1,
      hasMore: hasMore,
    ));
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