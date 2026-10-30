import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Returns 16 random bytes from a secure source, base64url-encoded.
String generateSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64UrlEncode(bytes);
}

/// Returns the hex SHA-256 digest of [salt] followed by [secret].
String hashSecret(String secret, String salt) =>
    sha256.convert(utf8.encode(salt + secret)).toString();
