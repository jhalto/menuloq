abstract class VerifyEmailEvent {
  const VerifyEmailEvent();
}

class VerifyEmailStarted extends VerifyEmailEvent {
  const VerifyEmailStarted({
    required this.email,
  });

  final String email;
}

class VerifyEmailTimerTicked extends VerifyEmailEvent {
  const VerifyEmailTimerTicked();
}

class VerifyEmailOtpSubmitted extends VerifyEmailEvent {
  const VerifyEmailOtpSubmitted({
    required this.code,
  });

  final String code;
}

class VerifyEmailResendRequested extends VerifyEmailEvent {
  const VerifyEmailResendRequested();
}