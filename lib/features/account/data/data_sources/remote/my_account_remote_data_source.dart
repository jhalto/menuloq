import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/handle_error.dart';
import 'package:menuloq/features/account/data/models/my_account_model.dart';
import 'package:menuloq/features/account/domain/entities/my_account_validation_exception.dart';
import 'package:menuloq/features/account/domain/params/change_password_params.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';

abstract class MyAccountRemoteDataSource {
  Future<MyAccountModel> getMyAccount();

  Future<MyAccountModel?> updateMyAccount(
    UpdateMyAccountParams params,
  );

  Future<String> changePassword(ChangePasswordParams params);
}

class MyAccountRemoteDataSourceImpl implements MyAccountRemoteDataSource {
  const MyAccountRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<MyAccountModel> getMyAccount() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myAccount,
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw const AppException(
          message: 'Invalid account response.',
        );
      }

      final json = Map<String, dynamic>.from(responseData);

      if (json['success'] != true) {
        throw AppException(
          message: json['message']?.toString() ??
              'Failed to retrieve account details.',
        );
      }

      return MyAccountModel.fromJson(json);
    } on DioException catch (error) {
      throw AppException(
        message: handleDioError(error),
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while loading account details.',
      );
    }
  }

  @override
  Future<MyAccountModel?> updateMyAccount(
    UpdateMyAccountParams params,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.myAccount,
        data: params.toJson(),
      );

      debugPrint('========== UPDATE ACCOUNT RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('=============================================');

      final responseData = response.data;

      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);

        if (json['success'] == false) {
          throw AppException(
            message: json['message']?.toString() ??
                'Failed to update account details.',
          );
        }

        if (_hasAccountPayload(json)) {
          return MyAccountModel.fromJson(json);
        }
      }

      return null;
    } on DioException catch (error) {
      debugPrint('========== UPDATE ACCOUNT ERROR RESPONSE ==========');
      debugPrint('Status Code: ${error.response?.statusCode}');
      debugPrint('Response Data: ${error.response?.data}');
      debugPrint('===================================================');

      if (error.response?.statusCode == 422) {
        final responseData = error.response?.data;

        throw MyAccountValidationException(
          message: _extractMessage(responseData),
          errors: _extractValidationErrors(responseData),
        );
      }

      throw AppException(
        message: handleDioError(error),
      );
    } on MyAccountValidationException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while updating account details.',
      );
    }
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.changePassword,
        data: params.toJson(),
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw const AppException(message: 'Invalid change password response.');
      }

      final json = Map<String, dynamic>.from(responseData);
      final message =
          json['message']?.toString() ?? 'Password changed successfully.';

      if (json['success'] == false) {
        throw AppException(message: message);
      }

      return message;
    } on DioException catch (error) {
      throw AppException(message: handleDioError(error));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while changing your password.',
      );
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          'Please check the entered information.';
    }

    return 'Please check the entered information.';
  }

  Map<String, String> _extractValidationErrors(dynamic data) {
    if (data is! Map) return {};

    final rawErrors = data['errors'];

    if (rawErrors is! Map) return {};

    return rawErrors.map<String, String>((key, value) {
      if (value is List && value.isNotEmpty) {
        return MapEntry(
          key.toString(),
          value.first.toString(),
        );
      }

      return MapEntry(
        key.toString(),
        value.toString(),
      );
    });
  }

  bool _hasAccountPayload(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is! Map) return false;

    final account = Map<String, dynamic>.from(data);

    return account['business'] is Map &&
        (account['user'] is Map || account.containsKey('name'));
  }
}
