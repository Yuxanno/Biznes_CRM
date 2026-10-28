import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  // ── Light ──
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  // ── Dark ──
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      fontFamily: null, // system default

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: c.background,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: c.background,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.rLarge,
          side: BorderSide(color: c.border, width: 1),
        ),
      ),

      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.4),
          elevation: 0,
          minimumSize: const Size(kMinTapTarget, 48),
          shape: RoundedRectangleBorder(borderRadius: Radii.rMedium),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.border),
          minimumSize: const Size(kMinTapTarget, 48),
          shape: RoundedRectangleBorder(borderRadius: Radii.rMedium),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
        ),
      ),

      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.danger),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
        iconColor: c.textSecondary,
        prefixIconColor: c.textSecondary,
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(color: c.border, space: 1),

      // ── Bottom Nav ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.navBarBg,
        indicatorColor: c.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: Radii.rXl),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceVariant,
        contentTextStyle: TextStyle(color: c.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: Radii.rMedium),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Tab Bar ──
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textSecondary,
        indicatorColor: c.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
      ),

      // ── Progress ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceVariant,
      ),

      // ── Extensions ──
      extensions: [c],
    );
  }
}
