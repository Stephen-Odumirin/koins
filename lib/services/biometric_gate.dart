import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

abstract interface class BiometricAuthenticator {
  Future<bool> canUseBiometrics();
  Future<bool> authenticate({required String reason});
}

typedef BiometricState = ({bool supported, int enrolledCount});

class LocalAuthBiometricGate implements BiometricAuthenticator {
  LocalAuthBiometricGate({
    Future<BiometricState> Function()? readState,
    Future<bool> Function(String reason)? run,
  })  : _readState = readState ?? _defaultReadState,
        _run = run ?? _defaultRun;

  final Future<BiometricState> Function() _readState;
  final Future<bool> Function(String reason) _run;

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<BiometricState> _defaultReadState() async {
    final supported = await _auth.isDeviceSupported();
    final enrolled = await _auth.getAvailableBiometrics();
    return (supported: supported, enrolledCount: enrolled.length);
  }

  static Future<bool> _defaultRun(String reason) => _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );

  @override
  Future<bool> canUseBiometrics() async {
    try {
      final state = await _readState();
      return state.supported && state.enrolledCount > 0;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _run(reason);
    } on PlatformException {
      return false;
    }
  }
}
