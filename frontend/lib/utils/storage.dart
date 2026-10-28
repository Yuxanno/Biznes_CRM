import 'package:shared_preferences/shared_preferences.dart';

/// In-memory cache of auth data.
/// Avoids repeated SharedPreferences disk reads on every request.
class Storage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';

  // Memory cache
  static String? _token;
  static String? _userId;
  static String? _username;
  static bool _loaded = false;

  /// Load once from disk into memory
  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _username = prefs.getString(_usernameKey);
    _loaded = true;
  }

  static Future<void> saveAuth({
    required String token,
    required String userId,
    required String username,
  }) async {
    // Update memory cache immediately
    _token = token;
    _userId = userId;
    _username = username;
    _loaded = true;
    // Persist to disk async
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_userIdKey, userId),
      prefs.setString(_usernameKey, username),
    ]);
  }

  static Future<void> clearAuth() async {
    _token = null;
    _userId = null;
    _username = null;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_usernameKey),
    ]);
  }

  static Future<String?> getToken() async {
    await _ensureLoaded();
    return _token;
  }

  static Future<String?> getUserId() async {
    await _ensureLoaded();
    return _userId;
  }

  static Future<String?> getUsername() async {
    await _ensureLoaded();
    return _username;
  }

  static Future<bool> isLoggedIn() async {
    await _ensureLoaded();
    return _token != null && _token!.isNotEmpty;
  }
}
