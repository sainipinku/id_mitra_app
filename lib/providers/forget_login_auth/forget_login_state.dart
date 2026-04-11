part of 'forget_login_cubit.dart';

sealed class ForgetLoginState {}

final class ForgetLoginInitial extends ForgetLoginState {}

final class ForgetLoginLoading extends ForgetLoginState {}

final class ForgetLoginSuccess extends ForgetLoginState {
  final String message;
  ForgetLoginSuccess({required this.message});
}

final class PasswordSuccess extends ForgetLoginState {
  final String message;
  PasswordSuccess({required this.message});
}

final class ForgetLoginResendSuccess extends ForgetLoginState {}
final class ForgetLoginNoFound extends ForgetLoginState {
  final String message;
  ForgetLoginNoFound({required this.message});
}

final class ForgetLoginFailed extends ForgetLoginState {}

final class ForgetLoginInternetError extends ForgetLoginState {}

final class ForgetLoginTimeout extends ForgetLoginState {}

final class ForgetLoginOnHold extends ForgetLoginState {
  final String message;
  ForgetLoginOnHold({required this.message});
}

class LogoutSuccess extends ForgetLoginState {
  final LogoutModel logoutModel;

  LogoutSuccess({required this.logoutModel});

  @override
  List<Object> get props => [logoutModel];
}
