abstract class ResetPasswordEvent {
  const ResetPasswordEvent();
}

class ResetPasswordStarted extends ResetPasswordEvent {
  const ResetPasswordStarted({required this.email});

  final String email;
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
}

class ResetPasswordOtpRequested extends ResetPasswordEvent {
  const ResetPasswordOtpRequested({required this.email});

  final String email;
}
