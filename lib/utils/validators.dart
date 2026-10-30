class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    if (!_emailRegex.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? positiveNumber(String? value, String label) {
    final required = requiredField(value, label);
    if (required != null) return required;
    final parsed = num.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return '$label must be a positive number';
    }
    return null;
  }

  /// A whole number of at least 1, for counts such as months.
  static String? positiveWholeNumber(String? value, String label) {
    final required = requiredField(value, label);
    if (required != null) return required;
    final parsed = num.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null ||
        !parsed.isFinite ||
        parsed < 1 ||
        parsed != parsed.truncate()) {
      return '$label must be a whole number of at least 1';
    }
    return null;
  }
}
