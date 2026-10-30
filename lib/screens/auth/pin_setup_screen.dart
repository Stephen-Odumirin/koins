import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/pin/adaptive_pin_pad.dart';
import '../../l10n/app_localizations.dart';

/// Mandatory PIN setup shown after login. The PIN is required, so Back is
/// blocked here and the only way forward is to set and confirm a PIN.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

/// Holds the two-step entry (create, then confirm) and saves the PIN on a
/// match.
class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pad = GlobalKey<AdaptivePinPadState>();
  String? _first;
  String? _error;
  bool _busy = false;

  Future<void> _onCompleted(String value) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    if (_first == null) {
      _pad.currentState?.clear();
      setState(() {
        _first = value;
        _error = null;
      });
      return;
    }
    if (value != _first) {
      _pad.currentState?.clear();
      setState(() {
        _first = null;
        _error = l10n.pinMismatch;
      });
      return;
    }
    _busy = true;
    try {
      await ref.read(pinStoreProvider).savePin(value);
      final offer = await ref.read(biometricGateProvider).canUseBiometrics();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(offer ? '/biometric-offer' : '/dashboard');
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final confirming = _first != null;
    return PopScope(
      canPop: false,
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
                    Text(
                      confirming ? l10n.pinConfirmPrompt : l10n.pinCreatePrompt,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AdaptivePinPad(
                      key: _pad,
                      length: 4,
                      onCompleted: _onCompleted,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
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
