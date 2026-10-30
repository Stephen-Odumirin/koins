import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/pin/adaptive_pin_pad.dart';
import '../../l10n/app_localizations.dart';

const _maxAttempts = 3;

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pad = GlobalKey<AdaptivePinPadState>();
  String? _error;
  bool _busy = false;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _setupBiometric();
  }

  Future<void> _setupBiometric() async {
    try {
      final enabled = await ref.read(pinStoreProvider).biometricsEnabled();
      if (!enabled) return;
      final available = await ref
          .read(biometricGateProvider)
          .canUseBiometrics();
      if (!available || !mounted) return;
      setState(() => _showBiometric = true);
      await _tryBiometric();
    } catch (_) {
      // Biometrics are optional; the PIN pad still works.
    }
  }

  Future<void> _tryBiometric() async {
    final reason = AppLocalizations.of(context)!.lockUnlockReason;
    final ok = await ref
        .read(biometricGateProvider)
        .authenticate(reason: reason);
    if (ok && mounted) _unlock();
  }

  /// Unlocks. After a cold-start lock the lock route replaced the splash, so
  /// there is nothing underneath: replace it with the dashboard.
  void _unlock() {
    final lock = ref.read(appLockProvider.notifier);
    final coldStart = lock.coldStart;
    lock.unlock();
    if (coldStart) {
      appNavigatorKey.currentState?.pushReplacementNamed('/dashboard');
    }
  }

  Future<void> _submit(String value) async {
    if (_busy || value.length != 4) return;
    final l10n = AppLocalizations.of(context)!;
    _busy = true;
    final pins = ref.read(pinStoreProvider);
    final lock = ref.read(appLockProvider.notifier);
    final auth = ref.read(authProvider.notifier);
    try {
      if (await pins.verifyPin(value)) {
        await pins.resetFailedAttempts();
        if (mounted) _unlock();
        return;
      }
      await pins.recordFailedAttempt();
      final left = _maxAttempts - await pins.failedAttempts();
      if (left <= 0) {
        await pins.resetFailedAttempts();
        await auth.logout();
        // Replaces every route, the lock route included, then clears the
        // lock state so a later sign-in can lock again.
        appNavigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
          arguments: l10n.lockTooManyAttempts,
        );
        lock.unlock();
        return;
      }
      if (!mounted) return;
      _pad.currentState?.clear();
      setState(
        () => _error = l10n.lockIncorrectPin(left),
      );
    } catch (_) {
      if (!mounted) return;
      _pad.currentState?.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lockCheckError)),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      // Back closes the app; it never reveals the screen under the lock.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.lockEnterPin, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    AdaptivePinPad(key: _pad, length: 4, onCompleted: _submit),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    if (_showBiometric) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        key: const Key('lock-biometric'),
                        onPressed: _tryBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n.lockUseBiometrics),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
