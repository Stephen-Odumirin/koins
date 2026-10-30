import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/naira_input_formatter.dart';

TextEditingValue _v(String t) => TextEditingValue(
  text: t,
  selection: TextSelection.collapsed(offset: t.length),
);

void main() {
  final f = NairaInputFormatter();

  test('typing 120000 shows ₦120,000 with the cursor at the end', () {
    final r = f.formatEditUpdate(_v(''), _v('120000'));
    expect(r.text, '₦120,000');
    expect(r.selection.baseOffset, r.text.length);
  });

  test('typing digit by digit keeps grouping', () {
    var current = _v('');
    for (final ch in '1200000'.split('')) {
      current = f.formatEditUpdate(current, _v('${current.text}$ch'));
    }
    expect(current.text, '₦1,200,000');
  });

  test('deleting keeps the grouping', () {
    final r = f.formatEditUpdate(_v('₦120,000'), _v('₦120,00'));
    expect(r.text, '₦12,000');
  });

  test('deleting the last digit empties the field', () {
    final r = f.formatEditUpdate(_v('₦1'), _v('₦'));
    expect(r.text, '');
  });

  test('empty stays empty and letters are ignored', () {
    expect(f.formatEditUpdate(_v(''), _v('')).text, '');
    expect(f.formatEditUpdate(_v(''), _v('abc')).text, '');
    expect(f.formatEditUpdate(_v('₦12'), _v('₦12x')).text, '₦12');
  });

  test('parseNaira strips the sign and separators', () {
    expect(parseNaira('₦120,000'), 120000);
    expect(parseNaira('120000'), 120000);
    expect(parseNaira(''), isNull);
    expect(parseNaira('₦'), isNull);
  });
}
