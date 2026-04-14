

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


part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {

  LoginCubit () : super (LoginInitial());

  ApiManager apiManager = ApiManager();

  constVerifyOtp(Map map) async {
    emit(OTPVerifyLoading());
    try {
      var response = await apiManager.postRequest(
          map, Config.baseUrl + Routes.otpVerify);
      debugPrint("response${response.body}");
      final jsonData = jsonDecode(response.body);  // FIXED HERE
      if (response.statusCode == 200) {

        LoginModel loginModel = LoginModel.fromJson(jsonData);
        print('Login user school: ${loginModel.user?.school}');
        print('Login user id: ${loginModel.user?.id}');

        // school data raw jsonData se extract karo
        final schoolData = (jsonData['user']?['school'] as Map<String, dynamic>?);
        print('Raw school data: $schoolData');

        // Save user locally
        await UserLocal.saveUser(loginModel.user);

        // Save school data locally
        if (schoolData != null) {
          await UserLocal.saveSchool(
            schoolId: schoolData['id']?.toString() ?? loginModel.user?.id?.toString() ?? '',
            schoolName: schoolData['name']?.toString() ?? '',
          );
        } else {
          // super_admin without school — use user id as fallback
          await UserLocal.saveSchool(
            schoolId: loginModel.user?.id?.toString() ?? '',
            schoolName: loginModel.user?.name ?? '',
          );
        }

        // Save token securely
        await UserSecureStorage.setToken(jsonData["token"]);
        emit(LoginSuccess(loginModel: loginModel, loginWithType: '', schoolData: schoolData));
      } else if (response.statusCode == 403 || response.statusCode == 400 || response.statusCode == 401) {
        final message = jsonData['message'] ?? "User not found";
        emit(OtpVerifyOnHold(message: message));
      } else {
        emit(LoginFailed());
      }
    } on SocketException {
      emit(LoginInternetError());
    } on TimeoutException {
      emit(LoginTimeout());
    } catch (e) {
      emit(LoginFailed());
    }
  }
  constSendOtp(Map map,String loginWithType) async {
    emit(LoginLoading());

    try {
      var response = await apiManager.postRequest(
        map,
        Config.baseUrl + Routes.sendOtp,
      );

      debugPrint("STATUS CODE => ${response.statusCode}");
      debugPrint("RESPONSE BODY => ${response.body}");

      if (response.body.isEmpty) {
        emit(LoginFailed());
        return;
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        LoginModel loginModel = LoginModel.fromJson(jsonData);
        emit(LoginSuccess(loginModel: loginModel,loginWithType: loginWithType));
      } else if (response.statusCode == 403) {
        final message = jsonData['message'] ?? "User not found";
        emit(LoginOnHold(message: message));
      } else if (response.statusCode == 404) {
        final message = jsonData['message'] ?? "User not found";
        emit(LoginNoFound(message: message));
      } else {
        emit(LoginFailed());
      }
    } on SocketException {
      emit(LoginInternetError());
    } on TimeoutException {
      emit(LoginTimeout());
    } on FormatException {
      /// 🔥 JSON ERROR FIX
      debugPrint("Invalid JSON format");
      emit(LoginFailed());
    } catch (e) {
      debugPrint("ERROR => $e");
      emit(LoginFailed());
    }
  }

  constLogoutFun() async {
    emit(LoginLoading());
    try {
      var response = await apiManager.postWithoutRequest(
          Config.baseUrl + Routes.authLogout
      );

      debugPrint("response ${response.body}");
      final jsonData = jsonDecode(response.body);  // FIXED HERE
      if (response.statusCode == 200) {

        LogoutModel logoutModel = LogoutModel.fromJson(jsonData);
        emit(LogoutSuccess(logoutModel: logoutModel));
      } else if (response.statusCode == 403) {
        final message = jsonData['message'] ?? "User not found";
        emit(LoginOnHold(message: message));
      }
    } on SocketException {
      emit(LoginInternetError());
    } on TimeoutException {
      emit(LoginTimeout());
    } catch (e) {
      debugPrint("ERROR => $e");
      emit(LoginFailed());
    }
  }
  constGenratePassPinFun(Map map) async {
    emit(LoginLoading());
    try {
      var response = await apiManager.postRequest(
        map,
        Config.baseUrl + Routes.setCredentails,
      );

      debugPrint("response ${response.body}");
      final jsonData = jsonDecode(response.body);  // FIXED HERE
      if (response.statusCode == 200) {

        final message = jsonData['message'] ?? "User not found";
        emit(PasswordSuccess(message: message));
      } else if (response.statusCode == 403) {
        final message = jsonData['message'] ?? "User not found";
        emit(LoginOnHold(message: message));
      }
    } on SocketException {
      emit(LoginInternetError());
    } on TimeoutException {
      emit(LoginTimeout());
    } catch (e) {
      debugPrint("ERROR => $e");
      emit(LoginFailed());
    }
  }
  constForgetPasswordVerifyOtp(Map map) async {
    emit(LoginLoading());
    try {
      var response = await apiManager.postRequest(
          map, Config.baseUrl + Routes.forgetPasswordVerifyOtp);
      debugPrint("response${response.body}");
      final jsonData = jsonDecode(response.body);  // FIXED HERE
      if (response.statusCode == 200) {
        final message = jsonData['message'] ?? "User not found";
        // Save token securely
        await UserSecureStorage.setToken(jsonData["token"]);
        emit(ForgetLoginSuccess(message: message));
      } else if (response.statusCode == 403 || response.statusCode == 400) {
        final message = jsonData['message'] ?? "User not found";
        emit(LoginOnHold(message: message));
      } else {
        emit(LoginFailed());
      }
    } on SocketException {
      emit(LoginInternetError());
    } on TimeoutException {
      emit(LoginTimeout());
    } catch (e) {
      emit(LoginFailed());
    }
  }
}