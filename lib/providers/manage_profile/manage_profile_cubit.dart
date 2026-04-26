import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/models/UserProfileModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manage_profile_state.dart';

class ManageProfileCubit extends Cubit<ManageProfileState> {
  ManageProfileCubit() : super(ManageProfileInitial());

  ApiManager apiManager = ApiManager();

  updateProfile(Map<String, String> map, File? image) async {
    emit(ManageProfileLoading());

    try {
      final fields = Map<String, String>.from(map);

      var response = await apiManager.multipartApiCall(
        url: Config.baseUrl + Routes.authProfileUpdate,
        fields: fields,
        images: image,
      );

      print("Update Profile Status: ${response.statusCode}");
      print("Update Profile Data: ${response.data}");
      print("Update Profile Message: ${response.message}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          UserProfileDetailsModel userProfileModel =
          UserProfileDetailsModel.fromJson(response.data);

          final userData = response.data['user'];
          String savedPhotoUrl = '';

          if (userData != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("name", userData['name'] ?? '');
            prefs.setString("email", userData['email'] ?? '');
            prefs.setString("phone", userData['phone']?.toString() ?? '');

            // ✅ Server ke saare possible photo keys check karo
            savedPhotoUrl = userData['profile_photo_url']?.toString() ?? '';
            if (savedPhotoUrl.isEmpty) {
              savedPhotoUrl = userData['profile_pic']?.toString() ?? '';
            }
            if (savedPhotoUrl.isEmpty) {
              savedPhotoUrl = userData['avatar']?.toString() ?? '';
            }
            if (savedPhotoUrl.isEmpty) {
              savedPhotoUrl = userData['photo']?.toString() ?? '';
            }

            if (savedPhotoUrl.isNotEmpty) {
              prefs.setString("profileImage", savedPhotoUrl);
              print("✅ Saved profileImage to prefs: $savedPhotoUrl");
            } else {
              // ✅ Agar server photo URL nahi deta, to prefs se purana URL lo
              savedPhotoUrl = prefs.getString("profileImage") ?? '';
              print("⚠️ Server ne photo URL nahi diya. Prefs se liya: $savedPhotoUrl");
            }
          }

          emit(ManageProfileSuccess(
            userProfileModel: userProfileModel,
            updatedPhotoUrl: savedPhotoUrl.isNotEmpty ? savedPhotoUrl : null,
          ));
        } else {
          emit(ManageProfileFailed(message: "Invalid response data"));
        }
      } else if (response.statusCode == 403) {
        emit(ManageProfileOnHold());
      } else {
        emit(ManageProfileFailed(
          message: response.data?["message"]?.toString() ??
              response.message?.toString() ??
              "Something went wrong",
        ));
      }
    } on SocketException {
      emit(ManageProfileFailed(message: "No Internet Connection"));
    } catch (e) {
      emit(ManageProfileFailed(message: e.toString()));
    }
  }
}