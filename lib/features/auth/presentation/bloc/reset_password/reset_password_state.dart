enum ResetPasswordStatus {
  initial,
  loading,
  success,
  failure,
  expired,
  passwordMismatch,
}

class ResetPasswordState {
  const ResetPasswordState({
    this.status = ResetPasswordStatus.initial,
    this.email = '',
    this.message,
  });

  final ResetPasswordStatus status;
  final String email;
  final String? message;

  ResetPasswordState copyWith({
    ResetPasswordStatus? status,
    String? email,
    String? message,
    bool clearMessage = false,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}