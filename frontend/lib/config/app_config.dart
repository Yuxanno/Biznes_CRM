class AppConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:3001/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // File size limits (bytes)
  static const int maxPhotoSize = 10 * 1024 * 1024; // 10 MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10 MB

  // App name
  static const String appName = 'Business Manager';
}
