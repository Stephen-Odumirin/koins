import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/validators.dart';
import 'package:savings_app/utils/validation_message.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () {
      expect(Validators.email(''), ValidationMessage.emailRequired);
      expect(Validators.email(null), ValidationMessage.emailRequired);
    });

    test('rejects bad format', () {
      expect(Validators.email('bad'), ValidationMessage.invalidEmail);
    });

    test('accepts valid email with surrounding spaces', () {
      expect(Validators.email(' test@bank.com '), isNull); // Review Focus 1
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(''), ValidationMessage.passwordRequired);
    });

    test('needs 8 characters', () {
      expect(
        Validators.password('Pass123'),
        ValidationMessage.passwordTooShort,
      );
    });

    test('accepts 8 characters', () {
      expect(Validators.password('Password'), isNull);
    });
  });

  group('Validators.requiredField', () {
    test('rejects whitespace only', () {
      expect(Validators.requiredField('   '), ValidationMessage.required);
    });
  });

  group('Validators.positiveNumber', () {
    test('accepts commas', () {
      expect(
        Validators.positiveNumber('1,000,000'),
        isNull,
      ); // Review Focus 2
    });

    test('rejects zero and non-numeric', () {
      expect(
        Validators.positiveNumber('0'),
        ValidationMessage.notPositive,
      );
      expect(
        Validators.positiveNumber('abc'),
        ValidationMessage.notPositive,
      );
    });

    test('requires a value', () {
      expect(Validators.positiveNumber(''), ValidationMessage.required);
    });
  });

  group('Validators finite and whole numbers', () {
    test('amounts reject Infinity and NaN', () {
      expect(
        Validators.positiveNumber('Infinity'),
        ValidationMessage.notPositive,
      );
      expect(
        Validators.positiveNumber('NaN'),
        ValidationMessage.notPositive,
      );
    });

    test('duration rejects fractions, zero, Infinity and NaN', () {
      const msg = ValidationMessage.notWholeNumber;
      expect(Validators.positiveWholeNumber('0.4'), msg);
      expect(Validators.positiveWholeNumber('1.5'), msg);
      expect(Validators.positiveWholeNumber('0'), msg);
      expect(Validators.positiveWholeNumber('Infinity'), msg);
      expect(Validators.positiveWholeNumber('NaN'), msg);
    });

    test('duration accepts whole numbers', () {
      expect(Validators.positiveWholeNumber('12'), isNull);
      expect(Validators.positiveWholeNumber('12.0'), isNull);
    });
  });
}
