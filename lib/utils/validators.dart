import 'validation_message.dart';

class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static ValidationMessage? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessage.required;
    }
    return null;
  }

  static ValidationMessage? email(String? value) {
    if (requiredField(value) != null) return ValidationMessage.emailRequired;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return ValidationMessage.invalidEmail;
    }
    return null;
  }

  static ValidationMessage? password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessage.passwordRequired;
    }
    if (value.length < 8) return ValidationMessage.passwordTooShort;
    return null;
  }

  static ValidationMessage? positiveNumber(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final parsed = num.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return ValidationMessage.notPositive;
    }
    return null;
  }

  /// A whole number of at least 1, for counts such as months.
  static ValidationMessage? positiveWholeNumber(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final parsed = num.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null ||
        !parsed.isFinite ||
        parsed < 1 ||
        parsed != parsed.truncate()) {
      return ValidationMessage.notWholeNumber;
    }
    return null;
  }
}
