/// The screen the app opens to after the splash.
enum StartupDestination { dashboard, login, onboarding }

/// Chooses the first screen shown after the splash.
///
/// Logged in always wins; otherwise onboarding gates the login screen.
StartupDestination resolveStartupDestination({
  required bool loggedIn,
  required bool onboardingComplete,
}) {
  if (loggedIn) return StartupDestination.dashboard;
  if (onboardingComplete) return StartupDestination.login;
  return StartupDestination.onboarding;
}
