import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:menuloq/features/auth/data/models/change_password_request_model.dart';
import 'package:menuloq/features/auth/data/models/login_request_model.dart';
import 'package:menuloq/features/auth/data/models/login_response_model.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/register_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> register({
    required String businessName,
    required String userName,
    required String ownerName,
    required String email,
    required String mobileNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = RegisterRequestModel(
      businessName: businessName,
      userName: userName,
      ownerName: ownerName,
      email: email,
      mobileNumber: mobileNumber,
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
    final request = LoginRequestModel(
      email: email,
      password: password,
    );

    return _remoteDataSource.login(request);
  }

  @override
  Future<void> getOtp({
    required String email,
  }) async {
    await _remoteDataSource.getOtp(email.trim());
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final request = VerifyOtpRequestModel(
      email: email,
      otp: otp,
    );

    await _remoteDataSource.verifyOtp(request);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final request = ChangePasswordRequestModel(
      
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await _remoteDataSource.changePassword(request);
  }
}
