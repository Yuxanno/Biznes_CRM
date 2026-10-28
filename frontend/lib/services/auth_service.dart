import '../models/user.dart';
import '../utils/storage.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<User> login(String username, String password) async {
    final data = await _api.post(
      '/auth/login',
      {'username': username, 'password': password},
      withAuth: false,
    );
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>, token);
    await Storage.saveAuth(
      token: token,
      userId: user.id,
      username: user.username,
    );
    return user;
  }

  Future<User> register(String username, String password) async {
    final data = await _api.post(
      '/auth/register',
      {'username': username, 'password': password},
      withAuth: false,
    );
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>, token);
    await Storage.saveAuth(
      token: token,
      userId: user.id,
      username: user.username,
    );
    return user;
  }

  Future<void> logout() async {
    await Storage.clearAuth();
  }

  Future<User?> tryAutoLogin() async {
    if (!await Storage.isLoggedIn()) return null;
    final token = await Storage.getToken();
    final userId = await Storage.getUserId();
    final username = await Storage.getUsername();
    if (token == null || userId == null || username == null) return null;
    return User(id: userId, username: username, token: token);
  }
}
