import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/l10n/app_localizations.dart';

void main() {
  test('the delegate supports and loads en', () async {
    expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.appName, 'KoinsMFB');
  });
}
