import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KoinsMFB'**
  String get appName;

  /// No description provided for @brandLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'KoinsMFB logo'**
  String get brandLogoLabel;

  /// No description provided for @createSavings.
  ///
  /// In en, this message translates to:
  /// **'Create savings'**
  String get createSavings;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @savingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your savings.'**
  String get savingsLoadError;

  /// No description provided for @savingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No savings plans yet. Create your first one.'**
  String get savingsEmpty;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Keep your savings in view'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'See your balance and your savings in one clear place.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Plan for what matters'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Set a goal, pick a plan and follow your progress towards it.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Your details stay protected'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected by your login, so only you can see it.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your progress. Please try again.'**
  String get onboardingSaveError;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your savings'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @loginComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get loginComingSoon;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginGenericError;

  /// No description provided for @welcomeNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KoinsMFB'**
  String get welcomeNotificationTitle;

  /// No description provided for @welcomeNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your savings are one tap away.'**
  String get welcomeNotificationBody;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinCreatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN'**
  String get pinCreatePrompt;

  /// No description provided for @pinConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmPrompt;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pinDelete;

  /// No description provided for @biometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricTitle;

  /// No description provided for @biometricHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock faster with biometrics'**
  String get biometricHeadline;

  /// No description provided for @biometricBody.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face instead of typing your PIN. Your PIN still works either way.'**
  String get biometricBody;

  /// No description provided for @biometricEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get biometricEnable;

  /// No description provided for @biometricNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get biometricNotNow;

  /// No description provided for @biometricConfirmReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric unlock'**
  String get biometricConfirmReason;

  /// No description provided for @biometricSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometrics weren\'t set up. You can still unlock with your PIN.'**
  String get biometricSetupFailed;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockEnterPin;

  /// No description provided for @lockUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get lockUseBiometrics;

  /// No description provided for @lockUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock KoinsMFB'**
  String get lockUnlockReason;

  /// No description provided for @lockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please log in again.'**
  String get lockTooManyAttempts;

  /// No description provided for @lockIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. {count, plural, =1{1 attempt} other{{count} attempts}} left.'**
  String lockIncorrectPin(int count);

  /// No description provided for @lockCheckError.
  ///
  /// In en, this message translates to:
  /// **'Could not check your PIN. Please try again.'**
  String get lockCheckError;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good Morning, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardViewProducts.
  ///
  /// In en, this message translates to:
  /// **'View products'**
  String get dashboardViewProducts;

  /// No description provided for @dashboardRecentSavings.
  ///
  /// In en, this message translates to:
  /// **'Recent savings'**
  String get dashboardRecentSavings;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardTotalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total savings'**
  String get dashboardTotalSavings;

  /// No description provided for @dashboardProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get dashboardProfileTooltip;

  /// No description provided for @dashboardHideAmount.
  ///
  /// In en, this message translates to:
  /// **'Hide amount'**
  String get dashboardHideAmount;

  /// No description provided for @dashboardShowAmount.
  ///
  /// In en, this message translates to:
  /// **'Show amount'**
  String get dashboardShowAmount;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings products'**
  String get productsTitle;

  /// No description provided for @productsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search savings products'**
  String get productsSearchHint;

  /// No description provided for @productsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get productsClearSearch;

  /// No description provided for @productsFlexibleOnly.
  ///
  /// In en, this message translates to:
  /// **'Flexible only'**
  String get productsFlexibleOnly;

  /// No description provided for @productsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load products.'**
  String get productsLoadError;

  /// No description provided for @productsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get productsNoMatch;

  /// No description provided for @productInterestChip.
  ///
  /// In en, this message translates to:
  /// **'{rate}% p.a.'**
  String productInterestChip(String rate);

  /// No description provided for @productViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get productViewDetails;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan details'**
  String get productDetailsTitle;

  /// No description provided for @statInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get statInterestRate;

  /// No description provided for @statMinimumDeposit.
  ///
  /// In en, this message translates to:
  /// **'Minimum deposit'**
  String get statMinimumDeposit;

  /// No description provided for @statDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get statDuration;

  /// No description provided for @planSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get planSavedLabel;

  /// No description provided for @planProductType.
  ///
  /// In en, this message translates to:
  /// **'Product type'**
  String get planProductType;

  /// No description provided for @planTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get planTarget;

  /// No description provided for @planSavedSoFar.
  ///
  /// In en, this message translates to:
  /// **'Saved so far'**
  String get planSavedSoFar;

  /// No description provided for @planMonthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution'**
  String get planMonthlyContribution;

  /// No description provided for @planDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get planDuration;

  /// No description provided for @planDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String planDurationMonths(int months);

  /// No description provided for @allSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'All savings'**
  String get allSavingsTitle;

  /// No description provided for @planTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{productType} · Monthly'**
  String planTileSubtitle(String productType);

  /// No description provided for @planTilePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} / mo'**
  String planTilePerMonth(String amount);

  /// No description provided for @createBackToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get createBackToDashboard;

  /// No description provided for @createSuccess.
  ///
  /// In en, this message translates to:
  /// **'Savings Created Successfully'**
  String get createSuccess;

  /// No description provided for @createSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your savings. Please try again.'**
  String get createSaveError;

  /// No description provided for @createReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your plan'**
  String get createReviewTitle;

  /// No description provided for @reviewName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reviewName;

  /// No description provided for @reviewProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get reviewProduct;

  /// No description provided for @reviewTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get reviewTarget;

  /// No description provided for @reviewMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reviewMonthly;

  /// No description provided for @reviewMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get reviewMonths;

  /// No description provided for @reviewOpeningDeposit.
  ///
  /// In en, this message translates to:
  /// **'Opening deposit'**
  String get reviewOpeningDeposit;

  /// No description provided for @createSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createSubmit;

  /// No description provided for @nameStepTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get nameStepTitle;

  /// No description provided for @nameStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings name'**
  String get nameStepLabel;

  /// No description provided for @productStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get productStepTitle;

  /// No description provided for @productStepSummary.
  ///
  /// In en, this message translates to:
  /// **'{rate}% a year · {duration} · from {minDeposit} a month'**
  String productStepSummary(String rate, String duration, String minDeposit);

  /// No description provided for @amountsTitle.
  ///
  /// In en, this message translates to:
  /// **'How much, and for how long?'**
  String get amountsTitle;

  /// No description provided for @amountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in two. We work out the third.'**
  String get amountsSubtitle;

  /// No description provided for @amountsTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get amountsTargetLabel;

  /// No description provided for @amountsMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly amount'**
  String get amountsMonthlyLabel;

  /// No description provided for @amountsMonthsLockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get amountsMonthsLockedLabel;

  /// No description provided for @amountsMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Months (1 to 60)'**
  String get amountsMonthsLabel;

  /// No description provided for @amountsOpeningLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening deposit (optional)'**
  String get amountsOpeningLabel;

  /// No description provided for @amountsAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get amountsAdjust;

  /// No description provided for @amountsSummary.
  ///
  /// In en, this message translates to:
  /// **'I\'ll save {monthly} every month for {count, plural, =1{1 month} other{{count} months}}.'**
  String amountsSummary(String monthly, int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get profileLoadError;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhone;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
