import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/errors/app_exception.dart';
import 'package:savings_app/providers/auth_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('login with demo credentials stores normalised email', () async {
    final container = await _container();

    await container
        .read(authProvider.notifier)
        .login(' Test@Bank.com ', 'Password123');

    expect(container.read(authProvider), 'test@bank.com'); // Review Focus 1
  });

  test('wrong password throws AppException and state stays null', () async {
    final container = await _container();

    await expectLater(
      container.read(authProvider.notifier).login('test@bank.com', 'wrongpass'),
      throwsA(isA<AppException>()),
    );
    expect(container.read(authProvider), isNull);
  });

  test('logout clears the session', () async {
    final container = await _container();
    await container
        .read(authProvider.notifier)
        .login('test@bank.com', 'Password123');

    await container.read(authProvider.notifier).logout();

    expect(container.read(authProvider), isNull);
  });
}
