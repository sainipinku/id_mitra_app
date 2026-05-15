part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class OTPVerifyLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginModel loginModel;
  final String loginWithType;
  final Map<String, dynamic>? schoolData;
  LoginSuccess({required this.loginModel, required this.loginWithType, this.schoolData});
}
final class ForgetLoginSuccess extends LoginState {
  final String message;
  ForgetLoginSuccess({required this.message});
}
final class PasswordSuccess extends LoginState {
  final String message;
  final String userType;
  PasswordSuccess({required this.message, this.userType = ''});
}

final class LoginResendSuccess extends LoginState {}
final class LoginNoFound extends LoginState {
  final String message;
  LoginNoFound({required this.message});
}

final class LoginFailed extends LoginState {}

final class LoginInternetError extends LoginState {}

final class LoginTimeout extends LoginState {}

final class LoginOnHold extends LoginState {
  final String message;
  LoginOnHold({required this.message});
}

final class OtpVerifyOnHold extends LoginState {
  final String message;
  OtpVerifyOnHold({required this.message});
}

class LogoutSuccess extends LoginState {
  final LogoutModel logoutModel;

  LogoutSuccess({required this.logoutModel});

  @override
  List<Object> get props => [logoutModel];
}
