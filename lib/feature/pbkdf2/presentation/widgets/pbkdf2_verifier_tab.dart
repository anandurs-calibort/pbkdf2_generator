import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/pbkdf2_generator_notifier.dart';

class Pbkdf2VerifierTab extends ConsumerWidget {
  const Pbkdf2VerifierTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pbkdf2GeneratorProvider);
    final notifier = ref.read(pbkdf2GeneratorProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify Derived Key',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the password and the parameters used to '
                'generate the original hash. These values can come '
                'from another device or application.',
          ),
          const SizedBox(height: 24),

          // Password
          TextFormField(
            key: const ValueKey('verifier_password'),
            obscureText: true,
            enabled: !state.isVerifying,
            onChanged: notifier.updateVerifyPassword,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),

          // Salt
          TextFormField(
            key: const ValueKey('verifier_salt'),
            enabled: !state.isVerifying,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: notifier.updateVerifySalt,
            decoration: const InputDecoration(
              labelText: 'Salt',
              hintText: 'Enter the original salt',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.grain),
            ),
          ),
          const SizedBox(height: 16),

          // Iterations
          TextFormField(
            key: const ValueKey('verifier_iterations'),
            enabled: !state.isVerifying,
            keyboardType: TextInputType.number,
            onChanged: notifier.updateVerifyIterations,
            decoration: const InputDecoration(
              labelText: 'Iterations',
              hintText: 'e.g. 600000',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.repeat),
            ),
          ),
          const SizedBox(height: 16),

          // Key length
          DropdownButtonFormField<int>(
            key: const ValueKey('verifier_key_length'),
            initialValue: state.verifyKeyLengthBytes,
            decoration: const InputDecoration(
              labelText: 'Derived Key Length',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.data_object),
            ),
            items: const [16, 24, 32, 64]
                .map(
                  (length) => DropdownMenuItem<int>(
                value: length,
                child: Text('$length bytes (${length * 8} bits)'),
              ),
            )
                .toList(),
            onChanged: state.isVerifying
                ? null
                : (value) {
              if (value != null) {
                notifier.updateVerifyKeyLength(value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Expected hash
          TextFormField(
            key: const ValueKey('verifier_expected_hash'),
            enabled: !state.isVerifying,
            minLines: 2,
            maxLines: 4,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: notifier.updateExpectedHash,
            decoration: const InputDecoration(
              labelText: 'Hash to Verify',
              hintText: 'Paste the hash you want to verify',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 24),

          if (state.verifierError != null) ...[
            Text(
              state.verifierError!,
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isVerifying
                      ? null
                      : () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    notifier.verifyHash();
                  },
                  icon: state.isVerifying
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.verified_outlined),
                  label: Text(
                    state.isVerifying ? 'Verifying...' : 'Verify',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: state.isVerifying
                    ? null
                    : notifier.resetVerifier,
                child: const Text('Reset'),
              ),
            ],
          ),

          if (state.isVerified != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.isVerified!
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isVerified!
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: state.isVerified!
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.isVerified!
                          ? 'Match — the derived key is valid.'
                          : 'No match — check the password, parameters, and hash.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: state.isVerified!
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
