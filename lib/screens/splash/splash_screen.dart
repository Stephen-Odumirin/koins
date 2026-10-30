import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_lock_provider.dart';
import '../../providers/providers.dart';
import '../../utils/startup_route.dart';
import '../../widgets/brand_loader.dart';

/// Shows the brand while the loading animation plays, then routes to the
/// first screen. Never stays longer than [_maxWait].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _maxWait = Duration(seconds: 3);
  static const _holdTime = Duration(seconds: 2);

  final Completer<void> _animationDone = Completer<void>();
  Timer? _maxTimer;
  Timer? _holdTimer;
  bool _navigated = false;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read once; _start and build use the same value.
    _reduced = MediaQuery.disableAnimationsOf(context);
  }

  Future<void> _start() async {
    if (!mounted) return;
    // Under reduced motion nothing animates, so route immediately.
    if (_reduced) {
      _goNext();
      return;
    }
    // The loader is a looping mark with no end of its own, so the hold is a
    // fixed 2 s.
    _holdTimer = Timer(_holdTime, () {
      if (!_animationDone.isCompleted) _animationDone.complete();
    });
    final Future<void> wait = _animationDone.future;
    // The timeout wins when the animation is slow or fails to load.
    final timeout = Completer<void>();
    _maxTimer = Timer(_maxWait, () {
      if (!timeout.isCompleted) timeout.complete();
    });
    await Future.any<void>([wait, timeout.future]);
    _maxTimer?.cancel();
    _holdTimer?.cancel();
    _goNext();
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    final storage = ref.read(localStorageProvider);
    final destination = resolveStartupDestination(
      loggedIn: storage.loggedInEmail != null,
      onboardingComplete: storage.onboardingComplete,
    );
    final route = switch (destination) {
      StartupDestination.dashboard => '/dashboard',
      StartupDestination.login => '/login',
      StartupDestination.onboarding => '/onboarding',
    };
    var target = route;
    if (destination == StartupDestination.dashboard) {
      // Fail closed: if the PIN check errors or hangs, go to login, which
      // needs the password, rather than strand the user or skip the lock.
      var hasPin = false;
      try {
        hasPin = await ref
            .read(pinStoreProvider)
            .hasPin()
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      if (!mounted) return;
      if (hasPin) {
        // The splash owns the cold-start lock: it replaces itself with the
        // lock route, and unlocking continues to the dashboard.
        ref.read(appLockProvider.notifier).lockOnColdStart();
        target = '/lock';
      }
    }
    Navigator.of(context).pushReplacementNamed(target);
  }

  @override
  void dispose() {
    _maxTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLoader(
              key: const Key('splash-logo'),
              size: 96,
              reduceMotion: _reduced,
            ),
          ],
        ),
      ),
    );
  }
}
