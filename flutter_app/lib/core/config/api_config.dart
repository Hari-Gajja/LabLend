import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Storage key for custom override if user changes it in Settings
  static const String customBaseUrlKey = 'custom_api_base_url';

  // Active base URL in memory
  static String? _activeBaseUrl;

  static void setBaseUrl(String url) {
    _activeBaseUrl = url.trim().endsWith('/')
        ? url.trim().substring(0, url.trim().length - 1)
        : url.trim();
  }

  static String get baseUrl {
    if (_activeBaseUrl != null && _activeBaseUrl!.isNotEmpty) {
      return _activeBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        // Android emulator maps 10.0.2.2 to host machine localhost
        return 'http://10.0.2.2:5000/api/v1';
      } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return 'http://localhost:5000/api/v1';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://10.0.2.2:5000/api/v1';
  }

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Cloudinary settings
  static const String defaultCloudinaryFolder = 'lablend/equipment';
}
