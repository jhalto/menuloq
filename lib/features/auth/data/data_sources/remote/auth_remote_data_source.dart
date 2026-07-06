import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/dio_client.dart';
import 'package:menuloq/core/network/handle_error.dart';

import '../../models/change_password_request_model.dart';
import '../../models/login_request_model.dart';
import '../../models/login_response_model.dart';
import '../../models/register_request_model.dart';
import '../../models/verify_otp_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterRequestModel request);
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> refreshToken(String accessToken);
  Future<void> getOtp(String email);
  Future<void> verifyOtp(VerifyOtpRequestModel request);
  Future<void> resetPassword(ResetPasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<void> register(RegisterRequestModel request) async {
    try {
      final response = await DioClient.dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint('Register success: ${response.data}');
      }
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await DioClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(String accessToken) async {
    try {
      final response = await DioClient.dio.post(
        ApiEndpoints.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } catch (_) {
      throw const AppException('Session expired. Please login again.');
    }
  }

  @override
  Future<void> getOtp(String email) async {
    try {
      final response = await DioClient.dio.post(
        ApiEndpoints.getOtp,
        data: {'email': email.trim()},
      );

      if (kDebugMode) {
        debugPrint('Get OTP success: ${response.data}');
      }
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> verifyOtp(VerifyOtpRequestModel request) async {
    try {
      if (kDebugMode) {
        debugPrint('REMOTE: verify OTP API calling');
        debugPrint('Email: ${request.email}');
        debugPrint('OTP: ${request.otp}');
      }

      final response = await DioClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint('Verify OTP success: ${response.data}');
      }
    } on DioException catch (e) {
      final message = handleDioError(e);

      if (kDebugMode) {
        debugPrint('Verify OTP failed');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
        debugPrint('Error Message: $message');
      }

      throw AppException(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected verify OTP error: $e');
      }

      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await DioClient.dio.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint('Reset password success: ${response.data}');
      }
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }
}
