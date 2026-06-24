enum AuthStatus {
  initial,
  loading,
  success,
  failure,
  emailNotVerified,
  inactive,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
  });

  final AuthStatus status;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}