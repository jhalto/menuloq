import 'package:dio/dio.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/handle_error.dart';
import 'package:menuloq/features/account/data/models/my_account_model.dart';
import 'package:menuloq/features/account/domain/entities/my_account_validation_exception.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';

abstract class MyAccountRemoteDataSource {
  Future<MyAccountModel> getMyAccount();

  Future<MyAccountModel?> updateMyAccount(
    UpdateMyAccountParams params,
  );
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
          'Invalid account response.',
        );
      }

      final json = Map<String, dynamic>.from(responseData);

      if (json['success'] != true) {
        throw AppException(
          json['message']?.toString() ??
              'Failed to retrieve account details.',
        );
      }

      return MyAccountModel.fromJson(json);
    } on DioException catch (error) {
      throw AppException(
        handleDioError(error),
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Something went wrong while loading account details.',
      );
    }
  }

  @override
  Future<MyAccountModel?> updateMyAccount(
    UpdateMyAccountParams params,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.myAccount,
        data: params.toJson(),
      );

      final responseData = response.data;

      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);

        if (json['success'] == false) {
          throw AppException(
            json['message']?.toString() ??
                'Failed to update account details.',
          );
        }

        if (_hasAccountPayload(json)) {
          return MyAccountModel.fromJson(json);
        }
      }

      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 422) {
        final responseData = error.response?.data;

        throw MyAccountValidationException(
          message: _extractMessage(responseData),
          errors: _extractValidationErrors(responseData),
        );
      }

      throw AppException(
        handleDioError(error),
      );
    } on MyAccountValidationException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Something went wrong while updating account details.',
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
