import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savings_app/core/theme/app_theme.dart';
import 'package:savings_app/models/app_notification.dart';
import 'package:savings_app/providers/notifications_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/repositories/profile_repository.dart';
import 'package:savings_app/screens/login/login_screen.dart';
import 'package:savings_app/screens/notifications/notifications_screen.dart';
import 'package:savings_app/screens/profile/profile_screen.dart';
import 'package:savings_app/services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/in_memory_secret_store.dart';
import 'package:savings_app/l10n/app_localizations.dart';

const _userJson =
    '{"firstName":"Emily","lastName":"Johnson","email":"emily.johnson.long.address@example.com","phone":"+1 555 0100"}';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({'logged_in_email': 'a@b.com'});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      profileRepositoryProvider.overrideWithValue(
        ProfileRepository(
          UserApiService(
            client: MockClient((_) async => http.Response(_userJson, 200)),
          ),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.read(notificationsProvider.notifier).deliver(
        AppNotification(
          id: '1',
          title: 'Your savings plan has reached a new milestone',
          body: 'You have saved more than half of your target amount.',
          receivedAt: DateTime(2026, 1, 1),
        ),
      );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.5),
          ),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in <String, Widget>{
    'login': const LoginScreen(),
    'profile': const ProfileScreen(),
    'notifications': const NotificationsScreen(),
  }.entries) {
    testWidgets('${entry.key} does not overflow at 1.5x text on 360x640',
        (tester) async {
      await _pump(tester, entry.value);
      expect(tester.takeException(), isNull);
    });
  }
}
