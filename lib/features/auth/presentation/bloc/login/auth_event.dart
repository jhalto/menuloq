abstract class AuthEvent {
  const AuthEvent();
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class VerifyEmailRequested extends AuthEvent {
  const VerifyEmailRequested();
}