import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class DioClient {
  DioClient._();

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (AppConfig.isDevelopment && kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('========== API REQUEST ==========');
            debugPrint('METHOD: ${options.method}');
            debugPrint('URL: ${options.uri}');
            debugPrint('HEADERS: ${options.headers}');
            debugPrint('BODY: ${options.data}');
            debugPrint('=================================');

            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('========== API RESPONSE =========');
            debugPrint('URL: ${response.realUri}');
            debugPrint('STATUS: ${response.statusCode}');
            debugPrint('DATA: ${response.data}');
            debugPrint('=================================');

            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('========== API ERROR =========');
            debugPrint('URL: ${error.requestOptions.uri}');
            debugPrint('METHOD: ${error.requestOptions.method}');
            debugPrint('STATUS: ${error.response?.statusCode}');
            debugPrint('MESSAGE: ${error.message}');
            debugPrint('RESPONSE: ${error.response?.data}');
            debugPrint('==============================');

            return handler.next(error);
          },
        ),
      );
    }

    return dio;
  }
}