import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../providers/providers.dart';

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
  final _controller = PinInputController();
  String? _first;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Clearing inside onCompleted re-enters the field's own listener and
  /// leaves its completion tracking stale, so the next PIN would never
  /// complete. Clear once the current change has finished.
  void _clearAfterCompletion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.clear();
    });
  }

  Future<void> _onCompleted(String value) async {
    if (_busy) return;
    if (_first == null) {
      _clearAfterCompletion();
      setState(() {
        _first = value;
        _error = null;
      });
      return;
    }
    if (value != _first) {
      _clearAfterCompletion();
      setState(() {
        _first = null;
        _error = "PINs don't match. Try again.";
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
    final theme = Theme.of(context);
    final confirming = _first != null;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set up your PIN'),
          automaticallyImplyLeading: false,
        ),
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
                      confirming ? 'Confirm your PIN' : 'Create a 4-digit PIN',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    MaterialPinField(
                      key: const Key('pin-setup-field'),
                      length: 4,
                      pinController: _controller,
                      autoFocus: true,
                      autoDismissKeyboard: false,
                      obscureText: true,
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
