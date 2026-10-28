import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom theme mode enum — avoids conflict with Flutter's [ThemeMode].
enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  static AppThemeMode fromString(String? s) {
    switch (s) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_theme';

  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode get mode => _mode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = AppThemeModeX.fromString(prefs.getString(_key));
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.label);
    notifyListeners();
  }

  /// Convert to Flutter's [ThemeMode] for MaterialApp.
  ThemeMode get materialThemeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
