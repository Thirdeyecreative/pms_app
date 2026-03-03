import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    final data = await ApiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );

    final token = data['access_token'];
    if (token == null) throw ApiException('No token in response');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);

    // Also store user id if available
    final userId = data['user_id'] ?? data['id'];
    if (userId != null) {
      await prefs.setString('user_id', userId.toString());
    }

    return getCurrentUser();
  }

  Future<UserModel> getCurrentUser() async {
    final data = await ApiClient.get('/auth/me');
    final user = UserModel.fromJson(data);

    // Cache user id
    final prefs = await SharedPreferences.getInstance();
    if (user.id.isNotEmpty) {
      await prefs.setString('user_id', user.id);
    }

    return user;
  }

  Future<void> logout({bool clockOut = false}) async {
    try {
      await ApiClient.post('/auth/logout', body: {'clock_out': clockOut});
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
