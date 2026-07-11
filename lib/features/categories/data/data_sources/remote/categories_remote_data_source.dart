import 'package:dio/dio.dart';
import 'package:menuloq/core/error/app_exception.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/core/network/handle_error.dart';
import 'package:menuloq/features/categories/domain/params/create_category_params.dart';

import '../../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<CategoriesPageModel> getCategories({
    required String query,
    required int perPage,
  });

  Future<String> createCategory(CreateCategoryParams params);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CategoriesPageModel> getCategories({
    required String query,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.categories,
        queryParameters: {
          'query': query.trim(),
          'per_page': perPage,
        },
      );

      if (response.data is Map) {
        return CategoriesPageModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      if (response.data is List) {
        return CategoriesPageModel.fromJson({
          'data': {'categories': response.data},
        });
      }

      return const CategoriesPageModel(
        categories: [],
        currentPage: 1,
        perPage: 10,
        total: 0,
        lastPage: 1,
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map && responseData['message'] != null) {
        throw AppException(message: responseData['message'].toString());
      }

      throw AppException(message: handleDioError(e));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while loading categories.',
      );
    }
  }

  @override
  Future<String> createCategory(CreateCategoryParams params) async {
    try {
      final formData = FormData();
      final requestData = params.toJson();

      for (final entry in requestData.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }

      final imageBytes = params.imageBytes;
      final imageFileName = params.imageFileName;
      if (imageBytes != null &&
          imageBytes.isNotEmpty &&
          imageFileName != null &&
          imageFileName.trim().isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(imageBytes, filename: imageFileName),
          ),
        );
      }

      final response = await _dio.post(ApiEndpoints.categories, data: formData);
      final responseData = response.data;

      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);
        if (json['success'] == false) {
          throw AppException(
            message:
                json['message']?.toString() ?? 'Failed to create category.',
            errors: _extractValidationErrors(json['errors']),
          );
        }

        return json['message']?.toString() ?? 'Category created successfully.';
      }

      return 'Category created successfully.';
    } on DioException catch (e) {
      final responseData = e.response?.data;

      if (responseData is Map) {
        final json = Map<String, dynamic>.from(responseData);
        throw AppException(
          message:
              json['message']?.toString() ?? 'Failed to create category.',
          errors: _extractValidationErrors(json['errors']),
        );
      }

      throw AppException(message: handleDioError(e));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Something went wrong while creating category.',
      );
    }
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic rawErrors) {
    if (rawErrors is! Map) return null;

    return rawErrors.map<String, List<String>>((key, value) {
      final messages = value is List
          ? value.map((item) => item.toString()).toList()
          : [value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
