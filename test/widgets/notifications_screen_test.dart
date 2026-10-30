import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/app_notification.dart';
import 'package:savings_app/providers/notifications_provider.dart';
import 'package:savings_app/screens/notifications/notifications_screen.dart';
import 'package:savings_app/l10n/app_localizations.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  List<AppNotification> items,
) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  for (final n in items) {
    container.read(notificationsProvider.notifier).deliver(n);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,home: NotificationsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows the empty state with no items', (tester) async {
    await _pump(tester, []);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('lists delivered items newest first', (tester) async {
    await _pump(tester, [
      AppNotification(id: '1', title: 'Older', body: 'x', receivedAt: DateTime(2026, 1, 1)),
      AppNotification(id: '2', title: 'Newer', body: 'y', receivedAt: DateTime(2026, 1, 2)),
    ]);
    final older = tester.getTopLeft(find.text('Older')).dy;
    final newer = tester.getTopLeft(find.text('Newer')).dy;
    expect(newer, lessThan(older));
  });

  testWidgets('opening the screen marks everything read', (tester) async {
    final container = await _pump(tester, [
      AppNotification(id: '1', title: 'A', body: 'x', receivedAt: DateTime(2026, 1, 1)),
    ]);
    expect(container.read(unreadCountProvider), 0);
  });
}
