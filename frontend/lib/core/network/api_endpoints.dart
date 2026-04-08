class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Notes
  static const String notes = '/notes';
  static String note(String id) => '/notes/$id';
  static String noteMindMap(String noteId) => '/notes/$noteId/mind-map';

  // Recognition
  static const String recognize = '/recognition/recognize';
  static const String recognitionProviders = '/recognition/providers';

  // Settings
  static const String settings = '/settings';
  static const String updateProvider = '/settings/ai-provider';
}
