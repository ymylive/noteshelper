class AppConfig {
  static const String appName = 'NotesHelper';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiVersion = '/api/v1';
  static String get apiUrl => '$apiBaseUrl$apiVersion';

  // Timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int uploadTimeout = 120000;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeKey = 'theme_mode';
  static const String defaultProviderKey = 'default_ai_provider';
}
