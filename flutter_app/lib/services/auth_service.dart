import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await _api.dio.post('/auth/send-otp', data: {'phone': phone});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await _api.dio.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'code': code},
    );
    final data = res.data as Map<String, dynamic>;
    await _api.saveTokens(data['access_token'], data['refresh_token']);
    return data;
  }

  Future<User> register({
    required String fullName,
    String? email,
    String? gender,
    String? birthDate,
  }) async {
    final res = await _api.dio.post(
      '/auth/register',
      data: {
        'full_name': fullName,
        if (email != null) 'email': email,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birth_date': birthDate,
      },
    );
    return User.fromJson(res.data);
  }

  Future<User> getMe() async {
    final res = await _api.dio.get('/users/me');
    return User.fromJson(res.data);
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getAccessToken();
    return token != null;
  }
}
