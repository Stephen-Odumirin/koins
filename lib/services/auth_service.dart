import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    // Simulated latency so the loading state is visible
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final ok = email.trim().toLowerCase() == AppConstants.mockEmail &&
        password == AppConstants.mockPassword;
    if (!ok) throw const AppException('Invalid email or password');
  }
}
