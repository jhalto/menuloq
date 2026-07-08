abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterBusinessStepSubmitted extends RegisterEvent {
  const RegisterBusinessStepSubmitted({
    required this.businessName,
    required this.subdomain,
    required this.ownerName,
    required this.email,
    required this.mobileNumber,
  });

  final String businessName;
  final String subdomain;
  final String ownerName;
  final String email;
  final String mobileNumber;
}

class RegisterBackToBusinessRequested extends RegisterEvent {
  const RegisterBackToBusinessRequested();
}

class RegisterBusinessFieldsChanged extends RegisterEvent {
  const RegisterBusinessFieldsChanged();
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.businessName,
    required this.userName,
    required this.ownerName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.passwordConfirmation,
  });

  final String businessName;
  final String userName;
  final String ownerName;
  final String email;
  final String mobileNumber;
  final String password;
  final String passwordConfirmation;
}
