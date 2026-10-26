
class Pbkdf2State {
  const Pbkdf2State({
    this.password = '',
    this.salt = '',
    this.iterations = '320000',
    this.keyLengthBytes = 32,
    this.generatedHash,
    this.isGenerating = false,
    this.generatorError,
    this.verifyPassword = '',
    this.verifySalt = '',
    this.verifyIterations = '320000',
    this.verifyKeyLengthBytes = 32,
    this.expectedHash = '',
    this.isVerifying = false,
    this.isVerified,
    this.verifierError,
  });

  // Generator state
  final String password;
  final String salt;
  final String iterations;
  final int keyLengthBytes;
  final String? generatedHash;
  final bool isGenerating;
  final String? generatorError;

  // Verifier state
  final String verifyPassword;
  final String verifySalt;
  final String verifyIterations;
  final int verifyKeyLengthBytes;
  final String expectedHash;
  final bool isVerifying;
  final bool? isVerified;
  final String? verifierError;

  Pbkdf2State copyWith({
    String? password,
    String? salt,
    String? iterations,
    int? keyLengthBytes,
    String? generatedHash,
    bool clearGeneratedHash = false,
    bool? isGenerating,
    String? generatorError,
    bool clearGeneratorError = false,
    String? verifyPassword,
    String? verifySalt,
    String? verifyIterations,
    int? verifyKeyLengthBytes,
    String? expectedHash,
    bool? isVerifying,
    bool? isVerified,
    bool clearIsVerified = false,
    String? verifierError,
    bool clearVerifierError = false,
  }) {
    return Pbkdf2State(
      password: password ?? this.password,
      salt: salt ?? this.salt,
      iterations: iterations ?? this.iterations,
      keyLengthBytes: keyLengthBytes ?? this.keyLengthBytes,
      generatedHash: clearGeneratedHash
          ? null
          : generatedHash ?? this.generatedHash,
      isGenerating: isGenerating ?? this.isGenerating,
      generatorError: clearGeneratorError
          ? null
          : generatorError ?? this.generatorError,
      verifyPassword: verifyPassword ?? this.verifyPassword,
      verifySalt: verifySalt ?? this.verifySalt,
      verifyIterations: verifyIterations ?? this.verifyIterations,
      verifyKeyLengthBytes:
      verifyKeyLengthBytes ?? this.verifyKeyLengthBytes,
      expectedHash: expectedHash ?? this.expectedHash,
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: clearIsVerified
          ? null
          : isVerified ?? this.isVerified,
      verifierError: clearVerifierError
          ? null
          : verifierError ?? this.verifierError,
    );
  }
}
