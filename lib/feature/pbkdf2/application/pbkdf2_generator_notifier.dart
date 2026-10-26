
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/crypto/pbkdf2_service.dart';
import '../models/pbkdf2_state.dart';
import 'dart:math';

part 'pbkdf2_generator_notifier.g.dart';

final pbkdf2ServiceProvider = Provider<Pbkdf2Service>(
      (ref) => Pbkdf2Service(),
);

@riverpod
class Pbkdf2GeneratorNotifier extends _$Pbkdf2GeneratorNotifier {
  final Random _secureRandom = Random.secure();

  Pbkdf2Service get _service => ref.read(pbkdf2ServiceProvider);

  @override
  Pbkdf2State build() {
    // Initialize the generator with a random salt.
    return Pbkdf2State().copyWith(
      salt: _createRandomSalt(),
    );
  }

  // ---------------------------------------------------------------------------
  // Random salt generation
  // ---------------------------------------------------------------------------

  String _createRandomSalt() {
    // Generate 16 cryptographically secure random bytes.
    final bytes = List<int>.generate(
      16,
          (_) => _secureRandom.nextInt(256),
    );

    // Convert the bytes to a 32-character hexadecimal string.
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Generates a new random salt and updates the generator state.
  String generateSalt() {
    if (state.isGenerating) return state.salt;

    final salt = _createRandomSalt();

    state = state.copyWith(
      salt: salt,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );

    return salt;
  }

  // ---------------------------------------------------------------------------
  // Generator input updates
  // ---------------------------------------------------------------------------

  void updatePassword(String value) {
    state = state.copyWith(
      password: value,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );
  }

  void updateSalt(String value) {
    state = state.copyWith(
      salt: value,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );
  }

  void updateIterations(String value) {
    state = state.copyWith(
      iterations: value,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );
  }

  void updateKeyLength(int value) {
    state = state.copyWith(
      keyLengthBytes: value,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Generate derived key
  // ---------------------------------------------------------------------------

  Future<void> generateHash() async {
    if (state.isGenerating) return;

    final password = state.password;
    final salt = state.salt;
    final iterations = int.tryParse(state.iterations);
    final keyLengthBytes = state.keyLengthBytes;

    if (password.isEmpty) {
      state = state.copyWith(
        generatorError: 'Password is required.',
        clearGeneratedHash: true,
      );
      return;
    }

    if (salt.isEmpty) {
      state = state.copyWith(
        generatorError: 'Salt is required.',
        clearGeneratedHash: true,
      );
      return;
    }

    if (iterations == null || iterations <= 0) {
      state = state.copyWith(
        generatorError: 'Enter a valid positive iteration count.',
        clearGeneratedHash: true,
      );
      return;
    }

    if (keyLengthBytes <= 0) {
      state = state.copyWith(
        generatorError: 'Key length must be positive.',
        clearGeneratedHash: true,
      );
      return;
    }

    state = state.copyWith(
      isGenerating: true,
      clearGeneratorError: true,
      clearGeneratedHash: true,
    );

    try {
      final hash = await _service.generateDerivedKey(
        password: password,
        salt: salt,
        iterations: iterations,
        keyLengthBytes: keyLengthBytes,
      );

      state = state.copyWith(
        generatedHash: hash,
      );
    } catch (_) {
      state = state.copyWith(
        generatorError: 'Unable to generate the derived key.',
        clearGeneratedHash: true,
      );
    } finally {
      state = state.copyWith(
        isGenerating: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reset generator
  // ---------------------------------------------------------------------------

  void resetGenerator() {
    if (state.isGenerating) return;

    state = state.copyWith(
      password: '',
      salt: _createRandomSalt(),
      iterations: '600000',
      keyLengthBytes: 32,
      clearGeneratedHash: true,
      clearGeneratorError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Verifier input updates
  // ---------------------------------------------------------------------------

  void updateVerifyPassword(String value) {
    state = state.copyWith(
      verifyPassword: value,
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }

  void updateVerifySalt(String value) {
    state = state.copyWith(
      verifySalt: value,
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }

  void updateVerifyIterations(String value) {
    state = state.copyWith(
      verifyIterations: value,
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }

  void updateVerifyKeyLength(int value) {
    state = state.copyWith(
      verifyKeyLengthBytes: value,
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }

  void updateExpectedHash(String value) {
    state = state.copyWith(
      expectedHash: value,
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Verify derived key
  // ---------------------------------------------------------------------------

  Future<void> verifyHash() async {
    if (state.isVerifying) return;

    final password = state.verifyPassword;
    final salt = state.verifySalt;
    final iterations = int.tryParse(state.verifyIterations);
    final keyLengthBytes = state.verifyKeyLengthBytes;
    final expectedHash = state.expectedHash.trim();

    if (password.isEmpty) {
      state = state.copyWith(
        verifierError: 'Password is required.',
        clearIsVerified: true,
      );
      return;
    }

    if (salt.trim().isEmpty) {
      state = state.copyWith(
        verifierError: 'Salt is required.',
        clearIsVerified: true,
      );
      return;
    }

    if (iterations == null || iterations <= 0) {
      state = state.copyWith(
        verifierError: 'Enter a valid positive iteration count.',
        clearIsVerified: true,
      );
      return;
    }

    if (keyLengthBytes <= 0) {
      state = state.copyWith(
        verifierError: 'Key length must be positive.',
        clearIsVerified: true,
      );
      return;
    }

    if (expectedHash.isEmpty) {
      state = state.copyWith(
        verifierError: 'Expected hash is required.',
        clearIsVerified: true,
      );
      return;
    }

    state = state.copyWith(
      isVerifying: true,
      clearVerifierError: true,
      clearIsVerified: true,
    );

    try {
      final result = await _service.verifyDerivedKey(
        password: password,
        salt: salt,
        iterations: iterations,
        keyLengthBytes: keyLengthBytes,
        expectedHash: expectedHash,
      );

      state = state.copyWith(isVerified: result);
    } catch (_) {
      state = state.copyWith(
        verifierError: 'Unable to verify the derived key.',
        clearIsVerified: true,
      );
    } finally {
      state = state.copyWith(isVerifying: false);
    }
  }


  // ---------------------------------------------------------------------------
  // Reset verifier
  // ---------------------------------------------------------------------------

  void resetVerifier() {
    if (state.isVerifying) return;

    state = state.copyWith(
      verifyPassword: '',
      verifySalt: '',
      verifyIterations: '320000',
      verifyKeyLengthBytes: 32,
      expectedHash: '',
      clearIsVerified: true,
      clearVerifierError: true,
    );
  }
}