import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/app_notification.dart';
import 'package:savings_app/services/mock_push_service.dart';

AppNotification _n(String id, DateTime at, {bool read = false}) =>
    AppNotification(id: id, title: 't$id', body: 'b$id', receivedAt: at, read: read);

void main() {
  test('starts empty', () {
    final s = MockPushService();
    expect(s.all(), isEmpty);
    expect(s.unreadCount(), 0);
  });

  test('deliver lists newest first', () {
    final s = MockPushService();
    s.deliver(_n('old', DateTime(2026, 1, 1)));
    s.deliver(_n('new', DateTime(2026, 1, 2)));
    expect(s.all().map((n) => n.id), ['new', 'old']);
  });

  test('unreadCount counts unread only', () {
    final s = MockPushService();
    s.deliver(_n('a', DateTime(2026, 1, 1)));
    s.deliver(_n('b', DateTime(2026, 1, 2), read: true));
    expect(s.unreadCount(), 1);
  });

  test('markAllRead sets all to read', () {
    final s = MockPushService();
    s.deliver(_n('a', DateTime(2026, 1, 1)));
    s.deliver(_n('b', DateTime(2026, 1, 2)));
    s.markAllRead();
    expect(s.unreadCount(), 0);
    expect(s.all().every((n) => n.read), isTrue);
  });
}
