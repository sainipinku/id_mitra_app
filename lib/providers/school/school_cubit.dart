

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
import 'package:idmitra/providers/school/school_state.dart';


class SchoolCubit extends Cubit<SchoolState> {
  SchoolCubit() : super(SchoolState());

  ApiManager apiManager = ApiManager();

  Future<void> fetchStudents({
    bool isLoadMore = false,
    String search = "",
  }) async {

    // 🔴 Prevent multiple calls
    if (state.isPaginationLoading || (!state.hasMore && isLoadMore)) return;

    int currentPage = isLoadMore ? state.page : 1;

    // 🔥 RESET LIST ON SEARCH
    if (!isLoadMore) {
      emit(state.copyWith(
        loading: true,
        page: 1,
        students: [],
        hasMore: true,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      final response = await apiManager.getRequest(
        "${Config.baseUrl}auth/partner/schools?page=$currentPage&search=$search",
      );

      final jsonData = jsonDecode(response.body);

      List list = jsonData["data"]?["schools"]?["data"] ?? [];

      List<SchoolDetailsModel> newList =
      list.map((e) => SchoolDetailsModel.fromJson(e)).toList();

      final total = jsonData["data"]["schools"]["total"] ?? 0;

      List<SchoolDetailsModel> updatedList = isLoadMore
          ? [...state.students, ...newList]
          : newList;

      bool hasMore = updatedList.length < total;

      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
        students: updatedList,
        page: currentPage + 1,
        hasMore: hasMore,
      ));

    } catch (e) {
      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
      ));
    }
  }
}