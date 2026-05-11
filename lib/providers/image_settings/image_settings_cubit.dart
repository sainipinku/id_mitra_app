import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';

part 'image_settings_state.dart';

class ImageSettingsCubit extends Cubit<ImageSettingsState> {
  ImageSettingsCubit() : super(ImageSettingsInitial());

  final ApiManager _apiManager = ApiManager();

  Future<void> fetchImageSettings({required String schoolId}) async {
    emit(ImageSettingsFetchLoading());
    try {
      final url = Config.baseUrl + Routes.updateImageSettings(schoolId);
      final response = await _apiManager.getRequest(url);

      if (response == null) {
        emit(ImageSettingsFetchFailed(message: "No response from server"));
        return;
      }

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API may return data directly or nested under 'settings'/'image_settings'
        final rawData = json["data"];
        final Map<String, dynamic> data;
        if (rawData is Map<String, dynamic>) {
          // Check if actual settings are nested deeper
          if (rawData.containsKey('image_settings') && rawData['image_settings'] is Map) {
            data = rawData['image_settings'] as Map<String, dynamic>;
          } else if (rawData.containsKey('settings') && rawData['settings'] is Map) {
            data = rawData['settings'] as Map<String, dynamic>;
          } else {
            data = rawData;
          }
        } else {
          data = {};
        }
        debugPrint('ImageSettings API data: $data');
        emit(ImageSettingsFetchLoaded(data: data));
      } else {
        emit(ImageSettingsFetchFailed(message: json["message"] ?? "Failed to load settings"));
      }
    } catch (e) {
      emit(ImageSettingsFetchFailed(message: e.toString()));
    }
  }

  Future<void> saveImageSettings({
    required String schoolId,
    required Map<String, dynamic> body,
  }) async {
    emit(ImageSettingsLoading());
    try {
      final url = Config.baseUrl + Routes.updateImageSettings(schoolId);
      final response = await _apiManager.putRequestWithBody(url, body);

      if (response == null) {
        emit(ImageSettingsFailed(message: "No response from server"));
        return;
      }

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final shape = json["data"]?["image_shape"]?.toString();
        emit(ImageSettingsSuccess(
          message: json["message"] ?? "Settings saved successfully",
          imageShape: shape,
        ));
      } else {
        emit(ImageSettingsFailed(message: json["message"] ?? "Something went wrong"));
      }
    } catch (e) {
      emit(ImageSettingsFailed(message: e.toString()));
    }
  }
}
