import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand palette ────────────────────────────────────────────────────────────
  static const primary     = Color(0xFF0061A4);
  static const secondary   = Color(0xFFD1E4FF);
  static const tertiary    = Color(0xFF535F70);
  static const neutral     = Color(0xFFFDFCFF);

  // ── Derived tones (Material You style) ───────────────────────────────────────
  static const primaryDark      = Color(0xFF004880);   // primary 80%
  static const primaryContainer = Color(0xFFD1E4FF);   // = secondary
  static const onPrimary        = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF001D36);

  static const surface      = Color(0xFF1A2332);       // dark surface
  static const surfaceVariant = Color(0xFF243044);     // card bg
  static const onSurface    = Color(0xFFE2E8F0);
  static const onSurfaceVariant = Color(0xFFB0BEC5);

  static const error   = Color(0xFFFF6B6B);
  static const success = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFD166);

  // ── Pomodoro specific ─────────────────────────────────────────────────────────
  static const pomodoroWork       = Color(0xFF0061A4);  // primary
  static const pomodoroShortBreak = Color(0xFF4ECDC4);  // teal
  static const pomodoroLongBreak  = Color(0xFF535F70);  // tertiary
}

abstract class AppTextStyles {
  static const displayLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 57, fontWeight: FontWeight.w400,
    color: AppColors.onSurface, letterSpacing: -0.25,
  );
  static const headlineLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static const headlineMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24, fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
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
  static const bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
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
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1923),
    colorScheme: const ColorScheme.dark(
      primary:            AppColors.primary,
      onPrimary:          AppColors.onPrimary,
      primaryContainer:   AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary:          AppColors.secondary,
      tertiary:           AppColors.tertiary,
      surface:            AppColors.surface,
      onSurface:          AppColors.onSurface,
      error:              AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F1923),
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
      color: AppColors.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: TextStyle(color: AppColors.tertiary.withOpacity(0.6)),
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
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
    ),
  );
}