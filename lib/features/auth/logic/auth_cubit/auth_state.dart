abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String message;

  AuthLoginSuccess(this.message);
}

class AuthSignupSuccess extends AuthState {
  final String message;

  AuthSignupSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthTogglePasswordVisibility extends AuthState {
  final bool isVisible;

  AuthTogglePasswordVisibility(this.isVisible);
}
