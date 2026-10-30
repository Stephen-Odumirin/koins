import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('logged-in email persists and clears', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await storage.saveLoggedInEmail('test@bank.com');
    expect(storage.loggedInEmail, 'test@bank.com');

    await storage.clearLoggedInUser();
    expect(storage.loggedInEmail, isNull);
  });

  test('onboarding is not complete by default', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    expect(storage.onboardingComplete, isFalse);
  });

  test('saving onboarding complete persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    await storage.saveOnboardingComplete();
    expect(storage.onboardingComplete, isTrue);
  });

  test('a non-bool onboarding value is treated as not complete', () async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': 'yes'});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    expect(storage.onboardingComplete, isFalse);
  });
}
