import 'package:menuloq/features/auth/data/models/login_response_model.dart';

abstract class AuthRepository {
  Future<void> register({
    required String businessName,
    required String userName,
    required String ownerName,
    required String email,
    required String mobileNumber,
    required String businessAddress,
    required bool termsAccepted,
    required String password,
    required String passwordConfirmation,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });
  Future<LoginResponseModel> refreshToken();

  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<void> getOtp({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String passwordConfirmation,
  });
}
