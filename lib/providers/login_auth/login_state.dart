part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginModel loginModel;
  LoginSuccess({required this.loginModel});
}

final class SignUpOtpSuccess extends LoginState {


}

final class LoginResendSuccess extends LoginState {}
final class LoginNoFound extends LoginState {
  final String message;
  LoginNoFound({required this.message});
}

final class LoginFailed extends LoginState {}

final class LoginInternetError extends LoginState {}

final class LoginTimeout extends LoginState {}

final class LoginOnHold extends LoginState {}

class LogoutSuccess extends LoginState {
  final LogoutModel logoutModel;

  LogoutSuccess({required this.logoutModel});

  @override
  List<Object> get props => [logoutModel];
}
