/// A stable key for a savings rule that the entered amounts break. The
/// widget maps it to localized text.
enum RuleError {
  /// Not enough input yet; no message is shown.
  incomplete,
  targetNotPositive,
  monthsRange,
  wrongTerm,
  belowMinimum,
  notMultipleOfMonths,
  notMultipleOfMonthly,
  openingExceedsTarget,
}
