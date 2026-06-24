abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterBusinessStepSubmitted extends RegisterEvent {
  const RegisterBusinessStepSubmitted({
    required this.businessName,
    required this.businessSlug,
    required this.ownerName,
    required this.email,
    required this.mobileNumber,
  });

  final String businessName;
  final String businessSlug;
  final String ownerName;
  final String email;
  final String mobileNumber;
}

class RegisterBackToBusinessRequested extends RegisterEvent {
  const RegisterBackToBusinessRequested();
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.password,
  });

  final String password;
}