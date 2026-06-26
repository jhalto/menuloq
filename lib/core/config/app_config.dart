
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get appEnv {
    return dotenv.env['APP_ENV'] ?? 'prod';
  }

  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'https://api.menuloq.com';
  }

  static bool get isProduction => appEnv == 'prod';
  static bool get isDevelopment => appEnv == 'dev';
  static bool get isStaging => appEnv == 'staging';
}