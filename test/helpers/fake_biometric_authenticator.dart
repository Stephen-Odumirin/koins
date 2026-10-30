import 'package:savings_app/services/biometric_gate.dart';

class FakeBiometricAuthenticator implements BiometricAuthenticator {
  FakeBiometricAuthenticator({this.canUse = true, this.result = false});

  bool canUse;
  bool result;
  int authenticateCalls = 0;

  @override
  Future<bool> canUseBiometrics() async => canUse;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    return result;
  }
}
