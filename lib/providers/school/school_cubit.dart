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
        error: null,
      ));
    } else {
      emit(state.copyWith(isPaginationLoading: true));
    }

    try {
      final response = await apiManager.getRequest(
        "${Config.baseUrl}auth/partner/schools?page=$currentPage&search=$search",
      );

      if (response == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: "No response from server"));
        return;
      }

      print('SchoolCubit API status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, error: "Unauthorized"));
        return;
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData["data"] == null || jsonData["data"]["schools"] == null) {
        emit(state.copyWith(loading: false, isPaginationLoading: false, students: [], hasMore: false));
        return;
      }

      List list = jsonData["data"]["schools"]["data"] ?? [];

      List<SchoolDetailsModel> newList = [];
      for (var e in list) {
        try {
          newList.add(SchoolDetailsModel.fromJson(e));
        } catch (parseErr, stackTrace) {
          newList.add(SchoolDetailsModel(
            id: e['id'],
            uuid: e['uuid']?.toString(),
            name: e['name']?.toString(),
            schoolPrefix: e['school_prefix']?.toString(),
            folderPrefix: e['folder_prefix']?.toString(),
            address: e['address']?.toString(),
            pincode: e['pincode']?.toString(),
            logoPhoto: e['logo_photo']?.toString(),
            logoUrl: e['logo_url']?.toString(),
            status: e['status'],
            partnerId: e['partner_id'],
            schoolAdminId: e['school_admin_id'],
            studentCount: e['student_count'],
            orderCount: e['order_count'],
            staffCount: e['staff_count'],
            countryId: e['country_id'],
            stateId: e['state_id'],
            cityId: e['city_id'],
            currentSession: e['current_session'],
            socialLinks: e['social_links'],
            deletedAt: e['deleted_at'],
            createdAt: e['created_at'] == null ? null : DateTime.tryParse(e['created_at']),
            updatedAt: e['updated_at'] == null ? null : DateTime.tryParse(e['updated_at']),
            studentFormFields: [],
            availableStudentFormFields: [],
          ));
        }
      }

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
      print('SchoolCubit fetchStudents error: $e');
      emit(state.copyWith(
        loading: false,
        isPaginationLoading: false,
        error: e.toString(),
      ));
    }
  }
}