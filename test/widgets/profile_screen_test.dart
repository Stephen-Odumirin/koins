import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savings_app/models/app_notification.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/repositories/profile_repository.dart';
import 'package:savings_app/screens/profile/profile_screen.dart';
import 'package:savings_app/services/mock_push_service.dart';
import 'package:savings_app/services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/in_memory_secret_store.dart';

const _userJson =
    '{"firstName":"Emily","lastName":"Johnson","email":"emily@example.com","phone":"+1 555 0100"}';

ProfileRepository _repo(http.Response Function() response) => ProfileRepository(
      UserApiService(client: MockClient((_) async => response())),
    );

MockPushService _serviceWith(List<AppNotification> items) {
  final service = MockPushService();
  items.forEach(service.deliver);
  return service;
}

Future<void> _pump(
  WidgetTester tester,
  ProfileRepository repo, {
  List<AppNotification> unread = const [],
}) async {
  SharedPreferences.setMockInitialValues({'logged_in_email': 'test@bank.com'});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        profileRepositoryProvider.overrideWithValue(repo),
        mockPushServiceProvider.overrideWithValue(
          _serviceWith(unread),
        ),
      ],
      child: MaterialApp(
        routes: {'/login': (_) => const Scaffold(body: Text('LOGIN'))},
        home: const ProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows name, email and phone from the API', (tester) async {
    await _pump(tester, _repo(() => http.Response(_userJson, 200)));

    expect(find.text('Emily Johnson'), findsOneWidget);
    expect(find.text('emily@example.com'), findsOneWidget);
    expect(find.text('+1 555 0100'), findsOneWidget);
  });

  testWidgets('API failure shows error state with retry', (tester) async {
    await _pump(tester, _repo(() => http.Response('', 500)));

    expect(find.text('Could not load your profile.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('logout returns to login', (tester) async {
    await _pump(tester, _repo(() => http.Response(_userJson, 200)));

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('shows a Notifications tile with an unread badge', (tester) async {
    await _pump(
      tester,
      _repo(() => http.Response(_userJson, 200)),
      unread: [
        AppNotification(id: '1', title: 'A', body: 'x', receivedAt: DateTime(2026, 1, 1)),
        AppNotification(id: '2', title: 'B', body: 'y', receivedAt: DateTime(2026, 1, 2)),
      ],
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.widgetWithText(Badge, '2'), findsOneWidget);
  });

  testWidgets('no badge when everything is read', (tester) async {
    await _pump(tester, _repo(() => http.Response(_userJson, 200)));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(Badge), findsNothing);
  });
}
