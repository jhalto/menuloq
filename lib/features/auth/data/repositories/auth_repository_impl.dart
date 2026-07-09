import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/models/change_password_request_model.dart';
import 'package:menuloq/features/auth/data/models/login_request_model.dart';
import 'package:menuloq/features/auth/data/models/login_response_model.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/register_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
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
  }) async {
    final request = RegisterRequestModel(
      businessName: businessName,
      userName: userName,
      ownerName: ownerName,
      email: email,
      mobileNumber: mobileNumber,
      businessAddress: businessAddress,
      termsAccepted: termsAccepted,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await _remoteDataSource.register(request);
  }

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestModel(email: email, password: password);

    final response = await _remoteDataSource.login(request);

    if (response.accessToken.trim().isEmpty) {
      throw const AppException(message: 'Login token not found.');
    }

    await _localDataSource.saveAuthData(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
      userId: response.user.id,
      userName: response.user.name,
      userEmail: response.user.email,
      businessId: response.business.id,
      businessName: response.business.businessName,
      businessUserName: response.business.userName,
    );

    return response;
  }

  @override
  Future<LoginResponseModel> refreshToken() async {
    final oldToken = await _localDataSource.getAccessToken();

    if (oldToken == null || oldToken.trim().isEmpty) {
      await _localDataSource.clearAuthData();
      throw const AppException(
        message: 'Session expired. Please login again.',
      );
    }

    final response = await _remoteDataSource.refreshToken(oldToken);

    if (response.accessToken.trim().isEmpty) {
      await _localDataSource.clearAuthData();
      throw const AppException(
        message: 'Session expired. Please login again.',
      );
    }

    await _localDataSource.saveAuthData(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
      userId: response.user.id,
      userName: response.user.name,
      userEmail: response.user.email,
      businessId: response.business.id,
      businessName: response.business.businessName,
      businessUserName: response.business.userName,
    );

    return response;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.hasAccessToken();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAllLocalData();
  }

  @override
  Future<void> getOtp({required String email}) async {
    await _remoteDataSource.getOtp(email.trim());
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    final request = VerifyOtpRequestModel(email: email, otp: otp);

    await _remoteDataSource.verifyOtp(request);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final request = ResetPasswordRequestModel(
      email: email,
      otp: otp,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );

    await _remoteDataSource.resetPassword(request);
  }
}
