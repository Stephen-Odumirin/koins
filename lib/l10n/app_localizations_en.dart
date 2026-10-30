// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KoinsMFB';

  @override
  String get brandLogoLabel => 'KoinsMFB logo';

  @override
  String get createSavings => 'Create savings';

  @override
  String get next => 'Next';

  @override
  String get tryAgain => 'Try again';

  @override
  String get savingsLoadError => 'Could not load your savings.';

  @override
  String get savingsEmpty => 'No savings plans yet. Create your first one.';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get onboardingSlide1Title => 'Keep your savings in view';

  @override
  String get onboardingSlide1Body =>
      'See your balance and your savings in one clear place.';

  @override
  String get onboardingSlide2Title => 'Plan for what matters';

  @override
  String get onboardingSlide2Body =>
      'Set a goal, pick a plan and follow your progress towards it.';

  @override
  String get onboardingSlide3Title => 'Your details stay protected';

  @override
  String get onboardingSlide3Body =>
      'Your account is protected by your login, so only you can see it.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSaveError =>
      'Couldn\'t save your progress. Please try again.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your savings';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginComingSoon => 'Coming soon';

  @override
  String get loginGenericError => 'Something went wrong. Please try again.';

  @override
  String get welcomeNotificationTitle => 'Welcome to KoinsMFB';

  @override
  String get welcomeNotificationBody => 'Your savings are one tap away.';

  @override
  String get pinSetupTitle => 'Set up your PIN';

  @override
  String get pinCreatePrompt => 'Create a 4-digit PIN';

  @override
  String get pinConfirmPrompt => 'Confirm your PIN';

  @override
  String get pinMismatch => 'PINs don\'t match. Try again.';

  @override
  String get pinDelete => 'Delete';

  @override
  String get biometricTitle => 'Biometric unlock';

  @override
  String get biometricHeadline => 'Unlock faster with biometrics';

  @override
  String get biometricBody =>
      'Use your fingerprint or face instead of typing your PIN. Your PIN still works either way.';

  @override
  String get biometricEnable => 'Enable';

  @override
  String get biometricNotNow => 'Not now';

  @override
  String get biometricConfirmReason => 'Confirm to enable biometric unlock';

  @override
  String get biometricSetupFailed =>
      'Biometrics weren\'t set up. You can still unlock with your PIN.';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockUseBiometrics => 'Use biometrics';

  @override
  String get lockUnlockReason => 'Unlock KoinsMFB';

  @override
  String get lockTooManyAttempts => 'Too many attempts. Please log in again.';

  @override
  String lockIncorrectPin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return 'Incorrect PIN. $_temp0 left.';
  }

  @override
  String get lockCheckError => 'Could not check your PIN. Please try again.';

  @override
  String get dashboardSubtitle => 'Here\'s your savings overview';

  @override
  String dashboardGreeting(String name) {
    return 'Good Morning, $name';
  }

  @override
  String get dashboardViewProducts => 'View products';

  @override
  String get dashboardRecentSavings => 'Recent savings';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardTotalSavings => 'Total savings';

  @override
  String get dashboardProfileTooltip => 'Open profile';

  @override
  String get dashboardHideAmount => 'Hide amount';

  @override
  String get dashboardShowAmount => 'Show amount';

  @override
  String get productsTitle => 'Savings products';

  @override
  String get productsSearchHint => 'Search savings products';

  @override
  String get productsClearSearch => 'Clear search';

  @override
  String get productsFlexibleOnly => 'Flexible only';

  @override
  String get productsLoadError => 'Could not load products.';

  @override
  String get productsNoMatch => 'No products match your search.';

  @override
  String productInterestChip(String rate) {
    return '$rate% p.a.';
  }

  @override
  String get productViewDetails => 'View details';

  @override
  String get productDetailsTitle => 'Plan details';

  @override
  String get statInterestRate => 'Interest rate';

  @override
  String get statMinimumDeposit => 'Minimum deposit';

  @override
  String get statDuration => 'Duration';

  @override
  String get planSavedLabel => 'saved';

  @override
  String get planProductType => 'Product type';

  @override
  String get planTarget => 'Target';

  @override
  String get planSavedSoFar => 'Saved so far';

  @override
  String get planMonthlyContribution => 'Monthly contribution';

  @override
  String get planDuration => 'Duration';

  @override
  String planDurationMonths(int months) {
    return '$months months';
  }

  @override
  String get allSavingsTitle => 'All savings';

  @override
  String planTileSubtitle(String productType) {
    return '$productType · Monthly';
  }

  @override
  String planTilePerMonth(String amount) {
    return '$amount / mo';
  }

  @override
  String get createBackToHome => 'Back to home';

  @override
  String get successDuration => 'Duration';

  @override
  String successMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get createSuccess => 'Savings Created Successfully';

  @override
  String get createSaveError =>
      'Could not save your savings. Please try again.';

  @override
  String get createReviewTitle => 'Review your plan';

  @override
  String get reviewName => 'Name';

  @override
  String get reviewProduct => 'Product';

  @override
  String get reviewTarget => 'Target';

  @override
  String get reviewMonthly => 'Monthly';

  @override
  String get reviewMonths => 'Months';

  @override
  String get reviewOpeningDeposit => 'Opening deposit';

  @override
  String get createSubmit => 'Create';

  @override
  String get nameStepTitle => 'What are you saving for?';

  @override
  String get nameStepLabel => 'Savings name';

  @override
  String get productStepTitle => 'Choose a product';

  @override
  String productStepSummary(String rate, String duration, String minDeposit) {
    return '$rate% a year · $duration · from $minDeposit a month';
  }

  @override
  String get amountsTitle => 'How much, and for how long?';

  @override
  String get amountsSubtitle => 'Fill in two. We work out the third.';

  @override
  String get amountsTargetLabel => 'Target amount';

  @override
  String get amountsMonthlyLabel => 'Monthly amount';

  @override
  String get amountsMonthsLockedLabel => 'Months';

  @override
  String get amountsMonthsLabel => 'Months (1 to 60)';

  @override
  String get amountsOpeningLabel => 'Opening deposit (optional)';

  @override
  String amountsSummary(String monthly, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return 'I\'ll save $monthly every month for $_temp0.';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadError => 'Could not load your profile.';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get profileLogout => 'Logout';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String validationRequired(String label) {
    return '$label is required';
  }

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String validationNotPositive(String label) {
    return '$label must be a positive number';
  }

  @override
  String validationNotWholeNumber(String label) {
    return '$label must be a whole number of at least 1';
  }

  @override
  String get ruleIncomplete => 'Complete the amounts.';

  @override
  String get ruleTargetNotPositive => 'Target must be more than zero.';

  @override
  String ruleMonthsRange(int max) {
    return 'Months must be a whole number from 1 to $max.';
  }

  @override
  String ruleWrongTerm(int months) {
    return 'This product runs for $months months.';
  }

  @override
  String get ruleBelowMinimum => 'Monthly amount is below the minimum.';

  @override
  String get ruleNotMultipleOfMonths =>
      'Target must be a multiple of the months.';

  @override
  String get ruleNotMultipleOfMonthly =>
      'Target must be a multiple of the monthly amount.';

  @override
  String get ruleOpeningExceedsTarget =>
      'Opening deposit cannot exceed the target.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String errorServer(int status) {
    return 'Server error ($status)';
  }

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorBadResponse => 'Unexpected response from server';

  @override
  String durationMonths(int months) {
    return '$months Months';
  }

  @override
  String get durationFlexible => 'Flexible';

  @override
  String get productTargetSavings => 'Target Savings';

  @override
  String get productTargetSavingsDescription =>
      'Save towards a specific goal with fixed monthly contributions.';

  @override
  String get productFixedDeposit => 'Fixed Deposit';

  @override
  String get productFixedDepositDescription =>
      'Lock funds for six months at a higher rate.';

  @override
  String get productEducationSavings => 'Education Savings';

  @override
  String get productEducationSavingsDescription =>
      'Build a fund for school fees, with withdrawals when you need them.';

  @override
  String get productVacationSavings => 'Vacation Savings';

  @override
  String get productVacationSavingsDescription =>
      'Plan your next trip with flexible withdrawals.';
}
