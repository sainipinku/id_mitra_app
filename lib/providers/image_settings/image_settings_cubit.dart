import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';

part 'image_settings_state.dart';

class ImageSettingsCubit extends Cubit<ImageSettingsState> {
  ImageSettingsCubit() : super(ImageSettingsInitial());

  final ApiManager _apiManager = ApiManager();

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
        emit(ImageSettingsSuccess(message: json["message"] ?? "Settings saved successfully"));
      } else {
        emit(ImageSettingsFailed(message: json["message"] ?? "Something went wrong"));
      }
    } catch (e) {
      emit(ImageSettingsFailed(message: e.toString()));
    }
  }
}
