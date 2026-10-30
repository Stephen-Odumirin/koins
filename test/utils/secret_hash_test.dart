import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/secret_hash.dart';

void main() {
  test('generateSalt returns different non-empty strings', () {
    final a = generateSalt();
    final b = generateSalt();
    expect(a, isNotEmpty);
    expect(b, isNotEmpty);
    expect(a, isNot(b));
  });

  test('hashSecret is deterministic', () {
    expect(hashSecret('1234', 's'), hashSecret('1234', 's'));
  });

  test('different salt gives different hash', () {
    expect(hashSecret('1234', 's1'), isNot(hashSecret('1234', 's2')));
  });

  test('hash is 64 hex characters', () {
    expect(hashSecret('1234', 's'), matches(RegExp(r'^[0-9a-f]{64}$')));
  });
}
