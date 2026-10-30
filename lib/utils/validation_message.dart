/// A stable key for a form validation problem. The widget maps it to
/// localized text; the validators stay free of any language.
enum ValidationMessage {
  /// A required field with a caller-supplied label is empty.
  required,
  emailRequired,
  invalidEmail,
  passwordRequired,
  passwordTooShort,
  notPositive,
  notWholeNumber,
}
