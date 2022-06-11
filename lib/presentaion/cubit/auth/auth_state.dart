abstract class AuthState {}

class AuthInitial extends AuthState {}


class LoadingRegisterState extends AuthState {}
class SuccessRegisterState extends AuthState {
  final String uId;

  SuccessRegisterState(this.uId);
}
class ErrorRegisterState extends AuthState {
  final String errorMessage;

  ErrorRegisterState(this.errorMessage);
}


class LoadingLoginState extends AuthState {}
class SuccessLoginState extends AuthState {
  final String uId;

  SuccessLoginState(this.uId);
}
class ErrorLoginState extends AuthState {
  final String errorMessage;

  ErrorLoginState(this.errorMessage);
}


class LoadingGetUserDataState extends AuthState {}
class SuccessGetUserDataState extends AuthState {}
class ErrorGetUserDataState extends AuthState {
  final String errorMessage;

  ErrorGetUserDataState(this.errorMessage);
}
