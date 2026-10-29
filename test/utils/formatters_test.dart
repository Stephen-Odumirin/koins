import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/formatters.dart';

void main() {
  test('formatNaira renders ₦850,000', () {
    expect(formatNaira(850000), '₦850,000');
  });

  test('formatNaira renders ₦5,000', () {
    expect(formatNaira(5000), '₦5,000');
  });
}
