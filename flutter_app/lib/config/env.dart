import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  Env._();

  static const bool isDev = String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev';
  static const String _apiOverride = String.fromEnvironment('API_BASE_URL');
  static String get apiBaseUrl => _apiOverride.isNotEmpty
      ? _apiOverride
      : kIsWeb
          ? 'http://localhost:8000/api/v1'
          : 'http://10.0.2.2:8000/api/v1';
  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');
}
