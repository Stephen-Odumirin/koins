import '../models/app_notification.dart';

/// Stands in for a push provider. Notifications are "delivered" by calling
/// [deliver] and are held in memory only, so they reset on every app start.
class MockPushService {
  final List<AppNotification> _items = [];

  /// All notifications, newest first.
  List<AppNotification> all() {
    final sorted = [..._items]
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return sorted;
  }

  /// Adds [n] to the inbox.
  void deliver(AppNotification n) => _items.add(n);

  /// Flags every notification as read.
  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].markedRead();
    }
  }

  /// How many notifications have not been read yet.
  int unreadCount() => _items.where((n) => !n.read).length;
}
