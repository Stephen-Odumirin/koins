import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../core/navigation.dart';
import '../screens/auth/lock_screen.dart';

/// Locks the app when it goes to the background (the splash owns the
/// cold-start lock), for a
/// signed-in user who has set a PIN.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  Route<void>? _lockRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lockIfNeeded();
    }
  }

  Future<void> _lockIfNeeded() async {
    if (ref.read(authProvider) == null) return;
    var hasPin = true; // fail closed: lock if the PIN check errors
    try {
      hasPin = await ref.read(pinStoreProvider).hasPin();
    } catch (_) {}
    // The user may have signed out while the PIN lookup was running.
    if (!mounted || !hasPin || ref.read(authProvider) == null) return;
    ref.read(appLockProvider.notifier).lock();
  }

  /// Shows or removes the lock route to match the lock state. The lock is a
  /// route on the app navigator so that Back is handled by its PopScope.
  void _sync(bool locked) {
    if (locked) {
      if (_lockRoute != null) return;
      // The splash replaced itself with the lock route on cold start.
      if (ref.read(appLockProvider.notifier).coldStart) return;
      final nav = appNavigatorKey.currentState;
      if (nav == null) {
        // The navigator is not built yet (cold start); try after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ref.read(appLockProvider)) _sync(true);
        });
        return;
      }
      final route = MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/lock'),
        builder: (_) => const LockScreen(),
      );
      _lockRoute = route;
      nav.push(route);
    } else {
      final route = _lockRoute;
      if (route == null) return;
      // Remove the lock wherever it sits in the stack; a no-op if already
      // gone. Clear the flag only after it is removed.
      appNavigatorKey.currentState?.removeRoute(route);
      _lockRoute = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(appLockProvider, (_, locked) => _sync(locked));
    return widget.child;
  }
}
