import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects bad format', () {
      expect(Validators.email('bad'), 'Enter a valid email address');
    });

    test('accepts valid email with surrounding spaces', () {
      expect(Validators.email(' test@bank.com '), isNull); // Review Focus 1
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('needs 8 characters', () {
      expect(Validators.password('Pass123'), 'Password must be at least 8 characters');
    });

    test('accepts 8 characters', () {
      expect(Validators.password('Password'), isNull);
    });
  });

  group('Validators.requiredField', () {
    test('rejects whitespace only', () {
      expect(Validators.requiredField('   ', 'Name'), 'Name is required');
    });
  });

  group('Validators.positiveNumber', () {
    test('accepts commas', () {
      expect(Validators.positiveNumber('1,000,000', 'Amount'), isNull); // Review Focus 2
    });

    test('rejects zero and non-numeric', () {
      expect(Validators.positiveNumber('0', 'Amount'), 'Amount must be a positive number');
      expect(Validators.positiveNumber('abc', 'Amount'), 'Amount must be a positive number');
    });

    test('requires a value', () {
      expect(Validators.positiveNumber('', 'Amount'), 'Amount is required');
    });
  });
}
