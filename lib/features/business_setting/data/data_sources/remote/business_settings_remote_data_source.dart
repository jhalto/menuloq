import 'package:dio/dio.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/handle_error.dart';

import '../../models/business_settings_model.dart';

abstract class BusinessSettingsRemoteDataSource {
  Future<BusinessSettingsModel> getBusinessSettings();
}

class BusinessSettingsRemoteDataSourceImpl
    implements BusinessSettingsRemoteDataSource {
  const BusinessSettingsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<BusinessSettingsModel> getBusinessSettings() async {
    try {
      final response = await _dio.get(ApiEndpoints.getBusinessSettings);

      if (response.data is! Map<String, dynamic>) {
        throw const AppException('Invalid business settings response.');
      }

      return BusinessSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw AppException(handleDioError(e));
    } on AppException {
      rethrow;
    } catch (e) {
      throw const AppException(
        'Something went wrong while loading business settings.',
      );
    }
  }
}