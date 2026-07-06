import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInstallGuard {
  const AppInstallGuard._();

  static const String _prefsInstallIdKey = 'menuloq_install_id_v1';
  static const String _secureInstallIdKey = 'menuloq_secure_install_id_v1';

  static Future<void> run({
    required FlutterSecureStorage secureStorage,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prefsInstallId = prefs.getString(_prefsInstallIdKey);
    final secureInstallId = await secureStorage.read(
      key: _secureInstallIdKey,
    );

    final hasPrefsInstallId =
        prefsInstallId != null && prefsInstallId.trim().isNotEmpty;

    final hasSecureInstallId =
        secureInstallId != null && secureInstallId.trim().isNotEmpty;

    // Normal app open / app update.
    // SharedPreferences still exists, so do not clear token.
    if (hasPrefsInstallId) {
      if (!hasSecureInstallId) {
        await secureStorage.write(
          key: _secureInstallIdKey,
          value: prefsInstallId,
        );
      }

      return;
    }

    // App data is fresh, but secure storage still has old install marker.
    // This usually means reinstall / secure storage survived uninstall.
    if (!hasPrefsInstallId && hasSecureInstallId) {
      await secureStorage.deleteAll();

      final newInstallId = _generateInstallId();

      await secureStorage.write(
        key: _secureInstallIdKey,
        value: newInstallId,
      );

      await prefs.setString(_prefsInstallIdKey, newInstallId);

      return;
    }

    // First time installing this guard.
    // Important: do not clear secure storage here.
    // This keeps existing logged-in users safe after app update.
    final newInstallId = _generateInstallId();

    await secureStorage.write(
      key: _secureInstallIdKey,
      value: newInstallId,
    );

    await prefs.setString(_prefsInstallIdKey, newInstallId);
  }

  static String _generateInstallId() {
    final random = Random.secure().nextInt(1 << 32);
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return 'menuloq_${timestamp}_$random';
  }
}