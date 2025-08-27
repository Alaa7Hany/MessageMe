abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String message;

  AuthLoginSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
