abstract class ForgotPasswordEvent {
  const ForgotPasswordEvent();
}

class ForgotPasswordOtpRequested extends ForgotPasswordEvent {
  const ForgotPasswordOtpRequested({
    required this.email,
  });

  final String email;
}