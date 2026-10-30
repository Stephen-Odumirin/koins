import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      tertiary: AppColors.accent,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      onSurface: isDark ? null : AppColors.heading,
      onSurfaceVariant: isDark ? null : AppColors.body,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
    );
    final fieldFill = isDark ? AppColors.darkCard : Colors.white;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          borderSide: BorderSide(color: color, width: width),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Manrope',
      // Manrope has no U+20A6 (Naira). Roboto ships with Android and has it.
      fontFamilyFallback: const ['Roboto', 'Noto Sans'],
      textTheme: Typography.material2021().black
          .merge(const TextTheme(
            headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            titleMedium: TextStyle(fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(height: 1.4, fontWeight: FontWeight.w400),
          ))
          .apply(
            fontFamily: 'Manrope',
            displayColor: isDark ? null : AppColors.heading,
            bodyColor: isDark ? null : AppColors.heading,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontFamilyFallback: const ['Roboto', 'Noto Sans'],
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? null : AppColors.heading,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      // Size.fromHeight gives buttons infinite minimum width. A button in a
      // Row or another unbounded-width parent must be wrapped in Expanded or
      // given an explicit width, or layout throws.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.keyMinSize),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.keyMinSize),
          shape: buttonShape,
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
        ),
      ),
    );
  }
}
