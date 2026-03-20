

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


part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {

  LoginCubit () : super (LoginInitial());

  ApiManager apiManager = ApiManager();

  constVerifyOtp(Map map) async {
    emit(LoginLoading());
    try {
      var response = await apiManager.postRequest(
          map, Config.baseUrl + Routes.otpVerify);
      debugPrint("response${response.body}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);  // FIXED HERE
        LoginModel loginModel = LoginModel.fromJson(jsonData);
        // Save user locally
        await UserLocal.saveUser(loginModel.user);

        // Save token securely
        await UserSecureStorage.setToken(jsonData["token"]);
        emit(LoginSuccess(loginModel: loginModel));
      } else if (response.statusCode == 403) {
        emit(LoginOnHold());
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
  constSendOtp(Map map) async {
    emit(LoginLoading());
    try {
      var response = await apiManager.postRequest(
          map,
          Config.baseUrl + Routes.sendOtp
      );

      debugPrint("response ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);  // FIXED HERE
        LoginModel loginModel = LoginModel.fromJson(jsonData);
        emit(LoginSuccess(loginModel: loginModel));
      } else if (response.statusCode == 403) {
        emit(LoginOnHold());
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

}