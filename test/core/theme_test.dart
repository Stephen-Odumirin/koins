import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_theme.dart';

void main() {
  test('light theme uses Material 3', () {
    expect(AppTheme.light().useMaterial3, isTrue);
  });

  test('dark theme is dark', () {
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
  });

  test('dark primary colour comes from the Koins green seed', () {
    expect(
      AppTheme.dark().colorScheme.primary,
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF81CB50),
        brightness: Brightness.dark,
      ).primary,
    );
  });

  test('primary colour comes from the Koins green seed', () {
    expect(
      AppTheme.light().colorScheme.primary,
      ColorScheme.fromSeed(seedColor: const Color(0xFF81CB50)).primary,
    );
  });
}
