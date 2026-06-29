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
    this.token,
    this.email,
  });

  final AuthStatus status;
  final String? message;
  final String? token;
  final String? email;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    String? token,
    String? email,
    bool clearMessage = false,
    bool clearToken = false,
    bool clearEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      token: clearToken ? null : (token ?? this.token),
      email: clearEmail ? null : (email ?? this.email),
    );
  }
}
