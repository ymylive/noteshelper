import 'package:noteshelper/core/network/api_client.dart';
import 'package:noteshelper/core/network/api_endpoints.dart';
import 'package:noteshelper/models/user.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;

    // Store tokens
    if (data['access_token'] != null) {
      await _client.setTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? '',
      );
    }

    return data;
  }

  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Logout even if the server call fails
    }
    await _client.clearTokens();
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.me);
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getStoredToken() async {
    return _client.getAccessToken();
  }

  Future<bool> refreshToken() async {
    // Handled by the interceptor, but can be called manually
    final token = await getStoredToken();
    return token != null;
  }
}
