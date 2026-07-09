import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/handle_error.dart';
import 'package:menuloq/features/business_setting/domain/params/update_business_settings_params.dart';

import '../../models/business_settings_model.dart';

abstract class BusinessSettingsRemoteDataSource {
  Future<BusinessSettingsModel> getBusinessSettings();

  Future<BusinessSettingsModel?> updateBusinessSettings(
    UpdateBusinessSettingsParams params,
  );
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
        throw const AppException(
          message: 'Invalid business settings response.',
        );
      }

      return BusinessSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw AppException(message: handleDioError(e));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while loading business settings.',
      );
    }
  }

  @override
  Future<BusinessSettingsModel?> updateBusinessSettings(
    UpdateBusinessSettingsParams params,
  ) async {
    try {
      final formData = FormData();
      final requestData = params.toJson();
      final deliveryOptions =
          requestData.remove('delivery_options[]') as List<String>? ?? const [];

      for (final entry in requestData.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }

      for (final option in deliveryOptions) {
        formData.fields.add(MapEntry('delivery_options[]', option));
      }

      final response = await _dio.post(
        ApiEndpoints.getBusinessSettings,
        data: formData,
      );

      debugPrint('========== BUSINESS SETTINGS UPDATE RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('=======================================================');

      final responseData = response.data;

      if (responseData is! Map) {
        return null;
      }

      final json = Map<String, dynamic>.from(responseData);

      if (json['success'] == false) {
        throw AppException(
          message:
              json['message']?.toString() ??
              'Failed to update business settings.',
        );
      }

      final responsePayload = json['data'];
      if (responsePayload is Map &&
          responsePayload['business'] is Map &&
          responsePayload['delivery_setting'] is Map &&
          responsePayload['options'] is Map) {
        return BusinessSettingsModel.fromJson(json);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('========== BUSINESS SETTINGS UPDATE ERROR ==========');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('=====================================================');

      throw AppException(message: handleDioError(e));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while updating business settings.',
      );
    }
  }
}
