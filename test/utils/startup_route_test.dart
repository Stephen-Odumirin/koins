import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/startup_route.dart';

void main() {
  test('logged in goes to dashboard, onboarding done or not', () {
    expect(
      resolveStartupDestination(loggedIn: true, onboardingComplete: true),
      StartupDestination.dashboard,
    );
    expect(
      resolveStartupDestination(loggedIn: true, onboardingComplete: false),
      StartupDestination.dashboard,
    );
  });

  test('logged out and onboarded goes to login', () {
    expect(
      resolveStartupDestination(loggedIn: false, onboardingComplete: true),
      StartupDestination.login,
    );
  });

  test('logged out and not onboarded goes to onboarding', () {
    expect(
      resolveStartupDestination(loggedIn: false, onboardingComplete: false),
      StartupDestination.onboarding,
    );
  });
}
