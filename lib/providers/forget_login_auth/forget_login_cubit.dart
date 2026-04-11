

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


part 'forget_login_state.dart';
class ForgetLoginCubit extends Cubit<ForgetLoginState> {

  ForgetLoginCubit () : super (ForgetLoginInitial());

  ApiManager apiManager = ApiManager();

  constForgetPasswordSendOtp(Map map) async {
    emit(ForgetLoginLoading());

    try {
      var response = await apiManager.postRequest(
        map,
        Config.baseUrl + Routes.forgetPasswordSendOtp,
      );

      debugPrint("STATUS CODE => ${response.statusCode}");
      debugPrint("RESPONSE BODY => ${response.body}");

      if (response.body.isEmpty) {
        emit(ForgetLoginFailed());
        return;
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final message = jsonData['message'] ?? "User not found";
        emit(ForgetLoginSuccess(message: message));
      } else if (response.statusCode == 403) {
        final message = jsonData['message'] ?? "User not found";
        emit(ForgetLoginOnHold(message: message));
      } else if (response.statusCode == 404) {
        final message = jsonData['message'] ?? "User not found";
        emit(ForgetLoginNoFound(message: message));
      } else {
        emit(ForgetLoginFailed());
      }
    } on SocketException {
      emit(ForgetLoginInternetError());
    } on TimeoutException {
      emit(ForgetLoginTimeout());
    } on FormatException {
      /// 🔥 JSON ERROR FIX
      debugPrint("Invalid JSON format");
      emit(ForgetLoginFailed());
    } catch (e) {
      debugPrint("ERROR => $e");
      emit(ForgetLoginFailed());
    }
  }



}