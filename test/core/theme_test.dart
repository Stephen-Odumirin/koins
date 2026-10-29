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
}
