enum VerifyEmailStatus {
  initial,
  loading,
  success,
  failure,
  expired,
  resendLoading,
  resendSuccess,
}

class VerifyEmailState {
  const VerifyEmailState({
    this.email = '',
    this.status = VerifyEmailStatus.initial,
    this.message,
    this.expiresIn = 600,
    this.resendIn = 60,
  });

  final String email;
  final VerifyEmailStatus status;
  final String? message;

  /// OTP expiry countdown in seconds.
  final int expiresIn;

  /// Resend cooldown in seconds.
  final int resendIn;

  bool get canResend => resendIn <= 0;
  bool get isExpired => expiresIn <= 0;

  VerifyEmailState copyWith({
    String? email,
    VerifyEmailStatus? status,
    String? message,
    bool clearMessage = false,
    int? expiresIn,
    int? resendIn,
  }) {
    return VerifyEmailState(
      email: email ?? this.email,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      expiresIn: expiresIn ?? this.expiresIn,
      resendIn: resendIn ?? this.resendIn,
    );
  }
}