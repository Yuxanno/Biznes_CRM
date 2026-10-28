import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Persistent HTTP client — reuses connections (Keep-Alive)
  final http.Client _client = http.Client();

  // Token cache — avoid SharedPreferences read on every request
  String? _cachedToken;
  DateTime? _tokenCachedAt;

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      // Cache token for 30 seconds to avoid repeated SharedPreferences reads
      final now = DateTime.now();
      if (_cachedToken == null ||
          _tokenCachedAt == null ||
          now.difference(_tokenCachedAt!).inSeconds > 30) {
        _cachedToken = await Storage.getToken();
        _tokenCachedAt = now;
      }
      if (_cachedToken != null) {
        headers['Authorization'] = 'Bearer $_cachedToken';
      }
    }
    return headers;
  }

  // Clear token cache on logout
  void clearCache() {
    _cachedToken = null;
    _tokenCachedAt = null;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    final message = body['error'] as String? ?? 'Unknown error';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path')
        .replace(queryParameters: query);
    final response = await _client
        .get(uri, headers: await _getHeaders(withAuth: withAuth))
        .timeout(AppConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client
        .post(uri,
            headers: await _getHeaders(withAuth: withAuth),
            body: jsonEncode(body))
        .timeout(AppConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client
        .put(uri, headers: await _getHeaders(), body: jsonEncode(body))
        .timeout(AppConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
      String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final response = await _client
        .patch(uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null)
        .timeout(AppConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
      String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path')
        .replace(queryParameters: query);
    final response = await _client
        .delete(uri, headers: await _getHeaders())
        .timeout(AppConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final token = _cachedToken ?? await Storage.getToken();
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    if (fields != null) request.fields.addAll(fields);
    final streamed =
        await request.send().timeout(AppConfig.receiveTimeout);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }
}
