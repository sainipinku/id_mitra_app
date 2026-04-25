part of 'manage_profile_cubit.dart';

sealed class ManageProfileState {}

final class ManageProfileInitial extends ManageProfileState {}

final class ManageProfileLoading extends ManageProfileState {}

final class ManageProfileSuccess extends ManageProfileState {
  final UserProfileDetailsModel userProfileModel;
  ManageProfileSuccess({required this.userProfileModel});
}

final class SignUpOtpSuccess extends ManageProfileState {


}

final class ManageProfileResendSuccess extends ManageProfileState {}

class ManageProfileFailed extends ManageProfileState {
  final String? message;
  ManageProfileFailed({this.message});
}


final class ManageProfileInternetError extends ManageProfileState {}

final class ManageProfileTimeout extends ManageProfileState {}

final class ManageProfileOnHold extends ManageProfileState {}

class RoleSelected extends ManageProfileState {
  final String selectedRole;

  RoleSelected({required this.selectedRole});

  @override
  List<Object> get props => [selectedRole];
}
