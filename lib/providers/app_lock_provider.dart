import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true means the app is locked behind the PIN screen.
class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// True when the splash locked the app on cold start. The splash then owns
  /// the lock route (it replaced itself with it), so LockGate must not push
  /// another one, and unlocking must continue to the dashboard.
  bool coldStart = false;

  void lock() => state = true;

  /// Locks on cold start; the caller shows the lock route itself.
  void lockOnColdStart() {
    coldStart = true;
    state = true;
  }

  void unlock() {
    coldStart = false;
    state = false;
  }
}

final appLockProvider =
    NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);
