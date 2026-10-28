import 'package:flutter/material.dart';

/// Color tokens for light & dark themes.
/// Access via `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ── Brand ──
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;

  // ── Semantic ──
  final Color income;
  final Color expense;
  final Color warning;
  final Color danger;

  // ── Surfaces ──
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // ── Status helpers ──
  final Color navBarBg;
  final Color shadow;

  const AppColors({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.income,
    required this.expense,
    required this.warning,
    required this.danger,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.navBarBg,
    required this.shadow,
  });

  // ── Light ──
  static const light = AppColors(
    primary: Color(0xFF6366F1),
    primaryContainer: Color(0xFFE4E5FF),
    onPrimary: Color(0xFFFFFFFF),
    income: Color(0xFF10B981),
    expense: Color(0xFFF43F5E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F2F5),
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1A1B23),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    navBarBg: Color(0xFFFFFFFF),
    shadow: Color(0x1A000000),
  );

  // ── Dark ──
  static const dark = AppColors(
    primary: Color(0xFF818CF8),
    primaryContainer: Color(0xFF3730A3),
    onPrimary: Color(0xFFFFFFFF),
    income: Color(0xFF34D399),
    expense: Color(0xFFFB7185),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    background: Color(0xFF0F0F14),
    surface: Color(0xFF1A1A24),
    surfaceVariant: Color(0xFF22222F),
    border: Color(0xFF2E2E3E),
    textPrimary: Color(0xFFF1F1F3),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF6B7280),
    navBarBg: Color(0xFF1A1A24),
    shadow: Color(0x33000000),
  );

  /// Helper to get status color for orders
  Color orderStatus(String status) {
    switch (status) {
      case 'new':
        return primary;
      case 'in_progress':
        return warning;
      case 'waiting':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return income;
      case 'cancelled':
        return textMuted;
      default:
        return textMuted;
    }
  }

  /// Helper to get status color for debts
  Color debtStatus(String status) {
    switch (status) {
      case 'unpaid':
        return danger;
      case 'partial':
        return warning;
      case 'paid':
        return income;
      default:
        return textSecondary;
    }
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimary,
    Color? income,
    Color? expense,
    Color? warning,
    Color? danger,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? navBarBg,
    Color? shadow,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      navBarBg: navBarBg ?? this.navBarBg,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Convenience extension for easy access.
extension AppColorsX on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
