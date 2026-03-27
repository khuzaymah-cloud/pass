class Env {
  Env._();

  static const bool isDev = String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');
}
