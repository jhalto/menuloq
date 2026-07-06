import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:menuloq/core/config/app_config.dart';
import 'package:menuloq/core/network/api_endpoints.dart';
import 'package:menuloq/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:menuloq/features/auth/data/models/login_response_model.dart';

class DioClient {
  DioClient._();

  static late final Dio dio;
  static late final Dio _refreshDio;

  static bool _isInitialized = false;

  static void init(AuthLocalDataSource authLocalDataSource) {
    debugPrint('DIO INIT CALLED');
    debugPrint('APP ENV: ${AppConfig.appEnv}');
    debugPrint('IS DEV: ${AppConfig.isDevelopment}');
    debugPrint('BASE URL: ${AppConfig.baseUrl}');
    if (_isInitialized) return;
    _isInitialized = true;

    dio = Dio(_baseOptions());
    _refreshDio = Dio(_baseOptions());

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicEndpoint = _isPublicEndpoint(options.path);

          if (!isPublicEndpoint) {
            final token = await authLocalDataSource.getAccessToken();
            final tokenType = await authLocalDataSource.getTokenType();

            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = '$tokenType $token';
            }
          }

          _logRequest(options);

          return handler.next(options);
        },

        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },

        onError: (error, handler) async {
          _logError(error);

          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final alreadyRetried = requestOptions.extra['retried'] == true;
          final isPublicEndpoint = _isPublicEndpoint(requestOptions.path);

          final shouldRefreshToken =
              statusCode == 401 && !alreadyRetried && !isPublicEndpoint;

          if (!shouldRefreshToken) {
            return handler.next(error);
          }

          try {
            final oldToken = await authLocalDataSource.getAccessToken();
            final tokenType = await authLocalDataSource.getTokenType();

            if (oldToken == null || oldToken.trim().isEmpty) {
              await authLocalDataSource.clearToken();
              return handler.next(error);
            }

            final refreshResponse = await _refreshDio.post(
              ApiEndpoints.refreshToken,
              options: Options(
                headers: {'Authorization': '$tokenType $oldToken'},
              ),
            );

            final loginResponse = LoginResponseModel.fromJson(
              refreshResponse.data as Map<String, dynamic>,
            );

            if (loginResponse.accessToken.trim().isEmpty) {
              await authLocalDataSource.clearToken();
              return handler.next(error);
            }

            await authLocalDataSource.saveToken(
              accessToken: loginResponse.accessToken,
              tokenType: loginResponse.tokenType,
              expiresIn: loginResponse.expiresIn,
            );

            requestOptions.extra['retried'] = true;
            requestOptions.headers['Authorization'] =
                '${loginResponse.tokenType} ${loginResponse.accessToken}';

            final retryResponse = await dio.fetch<dynamic>(requestOptions);

            return handler.resolve(retryResponse);
          } catch (e) {
            if (AppConfig.isDevelopment && kDebugMode) {
              debugPrint('========== REFRESH TOKEN FAILED ==========');
              debugPrint(e.toString());
              debugPrint('==========================================');
            }

            await authLocalDataSource.clearToken();

            return handler.next(error);
          }
        },
      ),
    );
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  static bool _isPublicEndpoint(String path) {
    final publicPaths = <String>{
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.getOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refreshToken,
    };

    return publicPaths.any((publicPath) {
      return path == publicPath || path.endsWith(publicPath);
    });
  }

  static void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    debugPrint('========== API REQUEST ==========');
    debugPrint('METHOsdD: ${options.method}');
    debugPrint('URL: ${options.uri}');
    debugPrint('HEADERS: ${_safeHeaders(options.headers)}');
    debugPrint('BODY: ${_safeBody(options.data)}');
    debugPrint('=================================');
  }

  static void _logResponse(Response<dynamic> response) {
    if (!AppConfig.isDevelopment || !kDebugMode) return;

    debugPrint('========== API RESPONSE =========');
    debugPrint('URL: ${response.realUri}');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('DATA: ${response.data}');
    debugPrint('=================================');
  }

  static void _logError(DioException error) {
    if (!AppConfig.isDevelopment || !kDebugMode) return;

    debugPrint('========== API ERROR =========');
    debugPrint('URL: ${error.requestOptions.uri}');
    debugPrint('METHOD: ${error.requestOptions.method}');
    debugPrint('STATUS: ${error.response?.statusCode}');
    debugPrint('MESSAGE: ${error.message}');
    debugPrint('RESPONSE: ${error.response?.data}');
    debugPrint('==============================');
  }

  static Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final safeHeaders = Map<String, dynamic>.from(headers);

    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = 'Bearer ***';
    }

    return safeHeaders;
  }

  static dynamic _safeBody(dynamic data) {
    if (data is! Map) return data;

    final safeData = Map<String, dynamic>.from(data);

    if (safeData.containsKey('password')) {
      safeData['password'] = '***';
    }

    if (safeData.containsKey('password_confirmation')) {
      safeData['password_confirmation'] = '***';
    }

    if (safeData.containsKey('old_password')) {
      safeData['old_password'] = '***';
    }

    if (safeData.containsKey('new_password')) {
      safeData['new_password'] = '***';
    }

    return safeData;
  }
}
