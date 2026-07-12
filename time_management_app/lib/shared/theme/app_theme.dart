import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand palette (Sky blue, light & cool) ──────────────────────────────────
  static const primary     = Color(0xFF2BAEE6);   // sky blue
  static const skyLight     = Color(0xFF6FCCF1);   // light sky
  static const tertiary    = Color(0xFF93A8B8);   // muted text / icon

  // ── Surfaces & backgrounds (bright) ──────────────────────────────────────────
  static const background       = Color(0xFFEAF2FB);   // app background (cool off-white blue)
  static const surface          = Color(0xFFFFFFFF);   // cards / sheets
  static const surfaceVariant   = Color(0xFFFFFFFF);   // cards / inputs
  static const inputFill        = Color(0xFFEFF5FB);   // input fields
  static const border           = Color(0xFFDCE8F2);   // subtle borders

  static const primaryContainer = Color(0xFFD8EEFB);
  static const onPrimary        = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF06354F);

  // ── Text ──────────────────────────────────────────────────────────────────────
  static const onSurface        = Color(0xFF12303F);   // primary text (dark slate)
  static const onSurfaceVariant = Color(0xFF5A7282);   // secondary text

  static const error   = Color(0xFFE5565B);
  static const success = Color(0xFF12B5A5);
  static const warning = Color(0xFFF5A524);

  // ── Pomodoro specific ─────────────────────────────────────────────────────────
  static const pomodoroWork       = Color(0xFF2BAEE6);  // primary sky
  static const pomodoroShortBreak = Color(0xFF12B5A5);  // teal
  static const pomodoroLongBreak  = Color(0xFF93A8B8);  // muted

  // ── Gradient dùng chung cho card/nút nổi bật ─────────────────────────────────
  static const skyGradient = [Color(0xFF56CCF2), Color(0xFF2BAEE6)];
}

abstract class AppTextStyles {
  static const titleLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  static const titleMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.onSurface, letterSpacing: 0.15,
  );
  static const bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );
  static const labelLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.onSurface, letterSpacing: 0.1,
  );
}

class AppTheme {
  /// Theme sáng, tông xanh da trời mát.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary:            AppColors.primary,
      onPrimary:          AppColors.onPrimary,
      primaryContainer:   AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary:          AppColors.primary,
      onSecondary:        AppColors.onPrimary,
      tertiary:           AppColors.tertiary,
      surface:            AppColors.surface,
      onSurface:          AppColors.onSurface,
      error:              AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge,
      iconTheme: IconThemeData(color: AppColors.onSurface),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.tertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: const TextStyle(color: AppColors.tertiary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryContainer,
      labelStyle: AppTextStyles.bodyMedium,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
    ),
  );
}
