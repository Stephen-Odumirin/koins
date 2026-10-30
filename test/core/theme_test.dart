import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_colors.dart';
import 'package:savings_app/core/theme/app_spacing.dart';
import 'package:savings_app/core/theme/app_theme.dart';
import 'package:savings_app/main.dart';

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
    expect(AppColors.surface, const Color(0xFFFFFFFF));
    expect(AppColors.outline, const Color(0xFFE4EADB));
    expect(AppColors.accent, const Color(0xFFF2A93B));
    expect(AppSpacing.radiusCard, 16);
    expect(AppSpacing.radiusField, 12);
    expect(AppSpacing.radiusButton, 14);
    expect(AppSpacing.radiusChip, 10);
    expect(AppSpacing.keyMinSize, 56);
  });

  test('filled buttons use a 14 px radius and 56 px minimum height', () {
    final style = AppTheme.light().filledButtonTheme.style!;
    final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(14));
    expect(style.minimumSize!.resolve({})!.height, 56);
  });

  test('outlined buttons use a 14 px radius', () {
    final style = AppTheme.light().outlinedButtonTheme.style!;
    final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(14));
  });

  test('inputs use a 12 px radius and cards 16 px with an outline', () {
    final theme = AppTheme.light();
    final input = theme.inputDecorationTheme.border! as OutlineInputBorder;
    expect(input.borderRadius, BorderRadius.circular(12));
    final card = theme.cardTheme.shape! as RoundedRectangleBorder;
    expect(card.borderRadius, BorderRadius.circular(16));
    expect(card.side.color, AppColors.outline);
    expect(theme.cardTheme.elevation, 0);
  });

  test('scaffold is white and app bar title uses Manrope', () {
    final theme = AppTheme.light();
    expect(theme.scaffoldBackgroundColor, Colors.white);
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'Manrope');
    expect(theme.appBarTheme.titleTextStyle?.fontSize, 18);
    expect(theme.appBarTheme.titleTextStyle?.fontWeight, FontWeight.w800);
    expect(theme.appBarTheme.backgroundColor, Colors.white);
    expect(theme.appBarTheme.elevation, 0);
  });

  test('every text style uses Manrope with the Naira fallback', () {
    final t = AppTheme.light().textTheme;
    for (final s in [
      t.displayLarge, t.headlineSmall, t.titleLarge, t.titleMedium,
      t.bodyLarge, t.bodyMedium, t.bodySmall, t.labelLarge, t.labelSmall,
    ]) {
      expect(s!.fontFamily, 'Manrope');
      expect(s.fontFamilyFallback, ['Roboto', 'Noto Sans']);
    }
  });

  testWidgets('SavingsApp hides the debug banner', (tester) async {
    late MaterialApp app;
    await tester.pumpWidget(Builder(builder: (context) {
      app = const SavingsApp().build(context) as MaterialApp;
      return const SizedBox();
    }));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });

  test('font keeps the Naira fallback', () {
    expect(AppTheme.light().textTheme.bodyMedium!.fontFamily, 'Manrope');
    expect(AppTheme.light().textTheme.bodyMedium!.fontFamilyFallback,
        ['Roboto', 'Noto Sans']);
  });
}
