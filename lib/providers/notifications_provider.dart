import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'providers.dart';

/// The inbox, newest first, backed by the mock push service.
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => ref.read(mockPushServiceProvider).all();

  /// Simulates a push arriving.
  void deliver(AppNotification n) {
    final service = ref.read(mockPushServiceProvider)..deliver(n);
    state = service.all();
  }

  /// Marks the whole inbox as read.
  void markAllRead() {
    final service = ref.read(mockPushServiceProvider)..markAllRead();
    state = service.all();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

/// Number of unread notifications, for badges.
final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationsProvider).where((n) => !n.read).length,
);
