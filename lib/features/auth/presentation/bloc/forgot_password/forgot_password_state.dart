enum ForgotPasswordStatus {
  initial,
  loading,
  success,
  failure,
}

class ForgotPasswordState {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.email = '',
    this.message,
  });

  final ForgotPasswordStatus status;
  final String email;
  final String? message;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    String? message,
    bool clearMessage = false,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}