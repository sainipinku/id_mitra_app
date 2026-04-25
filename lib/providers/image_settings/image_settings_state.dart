part of 'image_settings_cubit.dart';

abstract class ImageSettingsState {}

class ImageSettingsInitial extends ImageSettingsState {}

class ImageSettingsLoading extends ImageSettingsState {}

class ImageSettingsSuccess extends ImageSettingsState {
  final String message;
  ImageSettingsSuccess({required this.message});
}

class ImageSettingsFailed extends ImageSettingsState {
  final String message;
  ImageSettingsFailed({required this.message});
}
