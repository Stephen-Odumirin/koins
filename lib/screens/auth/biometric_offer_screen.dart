import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

/// Offered once after PIN setup when the device supports biometrics. The
/// PIN is already set, so Back is allowed and the user can always unlock
/// with it.
class BiometricOfferScreen extends ConsumerStatefulWidget {
  const BiometricOfferScreen({super.key});

  @override
  ConsumerState<BiometricOfferScreen> createState() =>
      _BiometricOfferScreenState();
}

/// Runs the enrolment check and moves on to the dashboard after a choice.
class _BiometricOfferScreenState extends ConsumerState<BiometricOfferScreen> {
  bool _busy = false;

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await ref
          .read(biometricGateProvider)
          .authenticate(reason: 'Confirm to enable biometric unlock');
      if (!mounted) return;
      if (ok) {
        await ref.read(pinStoreProvider).setBiometricsEnabled(true);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Biometrics weren't set up. You can still unlock with your PIN.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _later() => Navigator.of(context).pushReplacementNamed('/dashboard');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric unlock')),
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
                    Icons.fingerprint,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Unlock faster with biometrics',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use your fingerprint or face instead of typing your PIN. '
                    'Your PIN still works either way.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    key: const Key('biometric-enable'),
                    onPressed: _busy ? null : _enable,
                    child: const Text('Enable'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('biometric-later'),
                    onPressed: _busy ? null : _later,
                    child: const Text('Not now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
