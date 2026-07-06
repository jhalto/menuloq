 import 'package:dio/dio.dart';

String handleDioError(DioException e) {
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