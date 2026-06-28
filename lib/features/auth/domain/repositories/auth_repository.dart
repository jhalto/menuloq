abstract class AuthRepository {
  Future<void> register({
    required String businessName,
    required String userName,
    required String ownerName,
    required String email,
    required String mobileNumber,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> getOtp({
    required String email,
  });

  Future<void> verifyOtp({
    required String email,
    required String otp,
  });
}