import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _grouped = NumberFormat('#,###', 'en_US');

/// Shows `₦` and thousands separators while the user types. Anything that is
/// not a digit is dropped; an empty field stays empty.
class NairaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = '₦${_grouped.format(int.parse(digits))}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// The integer in a naira string such as `₦120,000`, or null when it has no
/// digits.
int? parseNaira(String text) =>
    int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
