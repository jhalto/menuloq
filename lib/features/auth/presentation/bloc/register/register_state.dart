enum RegisterStep { business, security }

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  const RegisterState({
    this.step = RegisterStep.business,
    this.status = RegisterStatus.initial,
    this.message,
    this.businessName = '',
    this.subdomain = '',
    this.ownerName = '',
    this.email = '',
    this.mobileNumber = '',
    this.emailError,
    this.subdomainError,
    this.mobileError,
  });

  final RegisterStep step;
  final RegisterStatus status;
  final String? message;

  final String businessName;
  final String subdomain;
  final String ownerName;
  final String email;
  final String mobileNumber;

  final String? emailError;
  final String? subdomainError;
  final String? mobileError;

  RegisterState copyWith({
    RegisterStep? step,
    RegisterStatus? status,
    String? message,
    bool clearMessage = false,
    String? businessName,
    String? subdomain,
    String? ownerName,
    String? email,
    String? mobileNumber,
    String? emailError,
    String? subdomainError,
    String? mobileError,
    bool clearFieldErrors = false,
  }) {
    return RegisterState(
      step: step ?? this.step,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      businessName: businessName ?? this.businessName,
      subdomain: subdomain ?? this.subdomain,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      emailError: clearFieldErrors ? null : emailError ?? this.emailError,
      subdomainError: clearFieldErrors ? null : subdomainError ?? this.subdomainError,
      mobileError: clearFieldErrors ? null : mobileError ?? this.mobileError,
    );
  }
}