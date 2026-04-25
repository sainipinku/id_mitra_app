






import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/UserProfileModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manage_profile_state.dart';
class ManageProfileCubit extends Cubit<ManageProfileState> {

  ManageProfileCubit () : super (ManageProfileInitial());

  ApiManager apiManager = ApiManager();

  updateProfile(Map<String, String> map, File? image) async {
    emit(ManageProfileLoading());

    try {
      var response = await apiManager.multipartApiCall(
        url: Config.baseUrl + Routes.authProfileUpdate,
        fields: map,
        images: image, // ✅ fixed
      );

      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data != null) {
          UserProfileDetailsModel userProfileModel =
          UserProfileDetailsModel.fromJson(response.data);

          // Save updated user info to local storage
          final userData = response.data['user'];
          if (userData != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("name", userData['name'] ?? '');
            prefs.setString("email", userData['email'] ?? '');
            prefs.setString("phone", userData['phone']?.toString() ?? '');
            prefs.setString("profileImage", userData['profile_photo_url'] ?? '');
          }

          emit(ManageProfileSuccess(userProfileModel: userProfileModel));
        } else {
          emit(ManageProfileFailed(message: "Invalid response data"));
        }
      } else if (response.statusCode == 403) {
        emit(ManageProfileOnHold());
      } else {
        emit(ManageProfileFailed(
          message: response.data?["message"]?.toString() ?? response.message?.toString() ?? "Something went wrong",
        ));
      }
    } on SocketException {
      emit(ManageProfileFailed(message: "No Internet Connection"));
    } catch (e) {
      emit(ManageProfileFailed(message: e.toString()));
    }
  }


}