
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class Pbkdf2Service {
  static const String algorithmName = 'PBKDF2-HMAC-SHA-256';

  Future<String> generateDerivedKey({
    required String password,
    required String salt,
    required int iterations,
    required int keyLengthBytes,
  }) async {
    if (password.isEmpty) {
      throw ArgumentError('Password is required.');
    }

    if (salt.isEmpty) {
      throw ArgumentError('Salt is required.');
    }

    if (iterations <= 0) {
      throw ArgumentError('Iterations must be greater than zero.');
    }

    if (keyLengthBytes <= 0) {
      throw ArgumentError('Key length must be greater than zero.');
    }

    final algorithm = Cryptography.instance.pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: keyLengthBytes * 8,
    );

    final derivedKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: utf8.encode(salt),
    );

    final bytes = await derivedKey.extractBytes();

    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<bool> verifyDerivedKey({
    required String password,
    required String salt,
    required int iterations,
    required int keyLengthBytes,
    required String expectedHash,
  }) async {
    final expected = expectedHash.trim().toLowerCase();

    if (expected.isEmpty) {
      throw ArgumentError('Expected hash is required.');
    }

    // A hexadecimal hash must contain an even number of valid hex characters.
    if (expected.length.isOdd ||
        !RegExp(r'^[0-9a-f]+$').hasMatch(expected)) {
      return false;
    }

    final actual = await generateDerivedKey(
      password: password,
      salt: salt,
      iterations: iterations,
      keyLengthBytes: keyLengthBytes,
    );

    if (actual.length != expected.length) {
      return false;
    }

    // Accumulate differences rather than returning at the first mismatch.
    var difference = 0;

    for (var i = 0; i < actual.length; i++) {
      difference |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }

    return difference == 0;
  }
}
