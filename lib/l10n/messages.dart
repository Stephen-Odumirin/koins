import '../core/errors/app_exception.dart';
import '../models/savings_product.dart';
import '../repositories/savings_repository.dart';
import '../utils/rule_error.dart';
import '../utils/savings_tally.dart';
import '../utils/validation_message.dart';
import 'app_localizations.dart';

/// Maps the stable keys returned by domain code to localized text.
extension DomainMessages on AppLocalizations {
  /// [label] names the field for the generic messages.
  String validationText(ValidationMessage m, {String label = ''}) =>
      switch (m) {
        ValidationMessage.required => validationRequired(label),
        ValidationMessage.emailRequired => validationEmailRequired,
        ValidationMessage.invalidEmail => validationInvalidEmail,
        ValidationMessage.passwordRequired => validationPasswordRequired,
        ValidationMessage.passwordTooShort => validationPasswordTooShort,
        ValidationMessage.notPositive => validationNotPositive(label),
        ValidationMessage.notWholeNumber => validationNotWholeNumber(label),
      };

  /// [fixedMonths] is the term of a fixed-term product.
  String ruleErrorText(RuleError e, {int? fixedMonths}) => switch (e) {
    RuleError.incomplete => ruleIncomplete,
    RuleError.targetNotPositive => ruleTargetNotPositive,
    RuleError.monthsRange => ruleMonthsRange(SavingsTally.maxMonths),
    RuleError.wrongTerm => ruleWrongTerm(fixedMonths ?? 0),
    RuleError.belowMinimum => ruleBelowMinimum,
    RuleError.notMultipleOfMonths => ruleNotMultipleOfMonths,
    RuleError.notMultipleOfMonthly => ruleNotMultipleOfMonthly,
    RuleError.openingExceedsTarget => ruleOpeningExceedsTarget,
  };

  String appExceptionText(AppException e) => switch (e.code) {
    AppExceptionCode.invalidCredentials => errorInvalidCredentials,
    AppExceptionCode.serverError => errorServer(e.statusCode ?? 0),
    AppExceptionCode.noInternet => errorNoInternet,
    AppExceptionCode.timeout => errorTimeout,
    AppExceptionCode.badResponse => errorBadResponse,
  };

  /// "12 Months", or "Flexible" when [months] is null.
  String durationText(int? months) =>
      months == null ? durationFlexible : durationMonths(months);

  /// The catalogue name of [p].
  String productName(SavingsProduct p) => switch (p.id) {
    'target' => productTargetSavings,
    'fixed' => productFixedDeposit,
    'education' => productEducationSavings,
    'vacation' => productVacationSavings,
    _ => p.id,
  };

  String productDescription(SavingsProduct p) => switch (p.id) {
    'target' => productTargetSavingsDescription,
    'fixed' => productFixedDepositDescription,
    'education' => productEducationSavingsDescription,
    'vacation' => productVacationSavingsDescription,
    _ => p.id,
  };

  /// A saved plan stores the catalogue key of its product (the product's
  /// [SavingsProduct.name]). Shows it in the user's language; an unknown
  /// key is shown as stored.
  String planProductTypeText(String stored) {
    for (final p in SavingsRepository.products) {
      if (p.name == stored || p.id == stored) return productName(p);
    }
    return stored;
  }
}
