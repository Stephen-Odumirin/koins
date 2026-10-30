/// A single push-style message shown in the notifications inbox.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool read;

  /// A copy of this notification flagged as read.
  AppNotification markedRead() => AppNotification(
        id: id,
        title: title,
        body: body,
        receivedAt: receivedAt,
        read: true,
      );
}
