

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        "${Config.baseUrl}auth/school/$schoolId?search=$search&page=$currentPage",
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
}