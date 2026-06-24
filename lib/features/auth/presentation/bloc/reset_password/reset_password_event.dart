abstract class ResetPasswordEvent {
  const ResetPasswordEvent();
}

class ResetPasswordStarted extends ResetPasswordEvent {
  const ResetPasswordStarted({
    required this.email,
  });

  final String email;
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted({
    required this.email,
    required this.code,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String code;
  final String password;
  final String confirmPassword;
}

class ResetPasswordOtpRequested extends ResetPasswordEvent {
  const ResetPasswordOtpRequested({
    required this.email,
  });

  final String email;
}