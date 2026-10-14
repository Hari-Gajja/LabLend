class ApiConfig {
  ApiConfig._();

  // Storage key for custom override if user changes it in Settings
  static const String customBaseUrlKey = 'custom_api_base_url';

  // Default production cloud backend URL
  static const String liveProductionUrl = 'https://backend-five-gamma-51.vercel.app/api/v1';

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
    // Default to the live deployed cloud server
    return liveProductionUrl;
  }

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Cloudinary settings
  static const String defaultCloudinaryFolder = 'lablend/equipment';
}
