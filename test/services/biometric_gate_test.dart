import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/services/biometric_gate.dart';

void main() {
  test('canUseBiometrics is false when nothing is enrolled', () async {
    final gate = LocalAuthBiometricGate(
      readState: () async => (supported: true, enrolledCount: 0),
    );
    expect(await gate.canUseBiometrics(), isFalse);
  });

  test('canUseBiometrics is false when the device is unsupported', () async {
    final gate = LocalAuthBiometricGate(
      readState: () async => (supported: false, enrolledCount: 1),
    );
    expect(await gate.canUseBiometrics(), isFalse);
  });

  test('canUseBiometrics is true when supported and one is enrolled', () async {
    final gate = LocalAuthBiometricGate(
      readState: () async => (supported: true, enrolledCount: 1),
    );
    expect(await gate.canUseBiometrics(), isTrue);
  });

  test('authenticate returns true only on success', () async {
    final gate = LocalAuthBiometricGate(run: (reason) async => true);
    expect(await gate.authenticate(reason: 'x'), isTrue);
    final failing = LocalAuthBiometricGate(run: (reason) async => false);
    expect(await failing.authenticate(reason: 'x'), isFalse);
  });

  test('authenticate returns false on PlatformException', () async {
    final gate = LocalAuthBiometricGate(
      run: (reason) async => throw PlatformException(code: 'NotAvailable'),
    );
    expect(await gate.authenticate(reason: 'x'), isFalse);
  });
}
