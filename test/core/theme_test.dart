import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_colors.dart';
import 'package:savings_app/core/theme/app_spacing.dart';
import 'package:savings_app/core/theme/app_theme.dart';

void main() {
  test('light theme uses Material 3', () {
    expect(AppTheme.light().useMaterial3, isTrue);
  });

  test('dark theme is dark', () {
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
  });

  test('light primary is the design-token primary', () {
    expect(AppTheme.light().colorScheme.primary, AppColors.primary);
  });

  test('dark surface is the dark token', () {
    expect(AppTheme.dark().colorScheme.surface, AppColors.darkSurface);
  });

  test('tokens carry the approved values', () {
    expect(AppColors.primary, const Color(0xFF5FA332));
    expect(AppColors.brand, const Color(0xFF81CB50));
    expect(AppColors.surface, const Color(0xFFF6F8F2));
    expect(AppColors.accent, const Color(0xFFF2A93B));
    expect(AppSpacing.radiusCard, 20);
    expect(AppSpacing.keyMinSize, 56);
  });

  test('filled buttons are pill shaped with a 56 px minimum height', () {
    final style = AppTheme.light().filledButtonTheme.style!;
    expect(style.shape!.resolve({}), isA<StadiumBorder>());
    expect(style.minimumSize!.resolve({})!.height, 56);
  });

  test('inputs are pill shaped and cards use a 20 px radius', () {
    final theme = AppTheme.light();
    expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    final card = theme.cardTheme.shape! as RoundedRectangleBorder;
    expect(card.borderRadius, BorderRadius.circular(20));
    expect(theme.cardTheme.elevation, 0);
  });

  test('font keeps the Naira fallback', () {
    expect(AppTheme.light().textTheme.bodyMedium!.fontFamily, 'Manrope');
    expect(AppTheme.light().textTheme.bodyMedium!.fontFamilyFallback,
        ['Roboto', 'Noto Sans']);
  });
}
