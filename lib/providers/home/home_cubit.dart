

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


part 'home_state.dart';
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  ApiManager apiManager = ApiManager();

  Future<void> loadHomeData() async {
    emit(state.copyWith(loading: true));

    try {
      /// 🔹 API 1 - Dashboard
      var dashboardResponse = await apiManager.getRequest(
        Config.baseUrl + Routes.getPartnerDashboardData(),
      );

      /// 🔹 API 2 - User Details
      var userResponse = await apiManager.getRequest(
        Config.baseUrl + Routes.getUserDetails(),
      );

      /// Null check — agar koi bhi response null hai toh error emit karo
      if (dashboardResponse == null || userResponse == null) {
        emit(state.copyWith(loading: false, error: "Server se response nahi mila"));
        return;
      }

      if (dashboardResponse.statusCode == 200 &&
          userResponse.statusCode == 200) {

        final dashboardBody = dashboardResponse.body.trim();
        final userBody = userResponse.body.trim();

        print('Dashboard response: $dashboardBody');
        print('User response: $userBody');

        // HTML response check - server ne error page diya
        if (userBody.startsWith('<') || dashboardBody.startsWith('<')) {
          emit(state.copyWith(loading: false, error: "Server error - invalid response"));
          return;
        }

        final dashboardJson = jsonDecode(dashboardBody);
        final userJson = jsonDecode(userBody);

        final dashboardModel = PartnerDashboardModel.fromJson(dashboardJson);
        final userModel = UserDetailsModel.fromJson(userJson);

        emit(state.copyWith(
          loading: false,
          dashboard: dashboardModel,
          user: userModel,
        ));
      } else if (dashboardResponse.statusCode == 403 ||
          userResponse.statusCode == 403) {
        emit(state.copyWith(loading: false, error: "On Hold"));
      } else if (dashboardResponse.statusCode == 404) {
        emit(state.copyWith(loading: false, error: "Dashboard API not found (404) — backend se check karein"));
      } else {
        emit(state.copyWith(
          loading: false,
          error: "Something went wrong (${dashboardResponse.statusCode})",
        ));
      }
    } catch (e, st) {
      print('HomeCubit error: $e\n$st');
      emit(state.copyWith(loading: false, error: "Error: ${e.toString()}"));
    }
  }
}