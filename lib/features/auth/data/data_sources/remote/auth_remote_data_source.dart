import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/dio_client.dart';

import '../../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<void> register(RegisterRequestModel request) async {
    try {
      debugPrint('REMOTE: register API calling body ${request.userName}');
      debugPrint('REMOTE: register API calling body ${request.businessName}');
      debugPrint('REMOTE: register API calling body ${request.email}');
      debugPrint('REMOTE: register API calling body ${request.ownerName}');
      debugPrint('REMOTE: register API calling body ${request.password}');
      debugPrint('REMOTE: register API calling body ${request.mobileNumber}');
      debugPrint('REMOTE: register API calling body ${request.passwordConfirmation}');
      
      final response = await DioClient.dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
        
      if (kDebugMode) {
        debugPrint('Register success: ${response.data}');
      }
    } on DioException catch (e) {
      final message = _handleDioError(e);

      if (kDebugMode) {
        debugPrint('Register failed');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
        debugPrint('Error Message: $message');
      }

      throw AppException(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected register error: $e');
      }

      throw const AppException('Something went wrong. Please try again.');
    }
  }

  String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 422 && data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final messages = <String>[];

        for (final value in errors.values) {
          if (value is List) {
            for (final item in value) {
              messages.add(item.toString());
            }
          } else {
            messages.add(value.toString());
          }
        }

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }

      return data['message']?.toString() ?? 'Validation failed.';
    }

    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    if (statusCode == 400) return 'Invalid request.';
    if (statusCode == 401) return 'Unauthorized request.';
    if (statusCode == 403) return 'You do not have permission.';
    if (statusCode == 404) return 'API endpoint not found.';
    if (statusCode == 500) return 'Server error. Please try again later.';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please check your internet.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection or server is unreachable.';
    }

    return 'Something went wrong. Please try again.';
  }
}
