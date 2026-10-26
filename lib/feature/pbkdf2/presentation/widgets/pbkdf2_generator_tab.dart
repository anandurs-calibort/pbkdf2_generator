
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/pbkdf2_service.dart';
import '../../application/pbkdf2_generator_notifier.dart';

class Pbkdf2GeneratorTab extends ConsumerStatefulWidget {
  const Pbkdf2GeneratorTab({super.key});

  @override
  ConsumerState<Pbkdf2GeneratorTab> createState() =>
      _Pbkdf2GeneratorTabState();
}

class _Pbkdf2GeneratorTabState
    extends ConsumerState<Pbkdf2GeneratorTab> {
  late final TextEditingController _saltController;

  @override
  void initState() {
    super.initState();

    // Read the initial salt from the provider.
    _saltController = TextEditingController(
      text: ref.read(pbkdf2GeneratorProvider).salt,
    );
  }

  @override
  void dispose() {
    _saltController.dispose();
    super.dispose();
  }

  void _updateSaltField(String salt) {
    _saltController.value = TextEditingValue(
      text: salt,
      selection: TextSelection.collapsed(
        offset: salt.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pbkdf2GeneratorProvider);
    final notifier = ref.read(pbkdf2GeneratorProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generate Derived Key',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a key using PBKDF2-HMAC-SHA-256.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Password
          TextFormField(
            key: const ValueKey('generator_password'),
            obscureText: true,
            enabled: !state.isGenerating,
            onChanged: notifier.updatePassword,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),

          // Salt with random generation suffix icon
          TextFormField(
            key: const ValueKey('generator_salt'),
            controller: _saltController,
            enabled: !state.isGenerating,
            onChanged: notifier.updateSalt,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Salt',
              hintText: 'Enter salt or generate a random one',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.grain),
              suffixIcon: IconButton(
                tooltip: 'Generate random salt',
                icon: const Icon(Icons.shuffle),
                onPressed: state.isGenerating
                    ? null
                    : () {
                  final salt = notifier.generateSalt();
                  _updateSaltField(salt);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A random salt is generated automatically. '
                'You can edit it manually or tap the shuffle icon '
                'to generate another.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Algorithm
          const InputDecorator(
            decoration: InputDecoration(
              labelText: 'Algorithm',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.security),
            ),
            child: Text(Pbkdf2Service.algorithmName),
          ),
          const SizedBox(height: 16),

          // Iterations
          TextFormField(
            key: const ValueKey('generator_iterations'),
            initialValue: state.iterations,
            enabled: !state.isGenerating,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: notifier.updateIterations,
            decoration: const InputDecoration(
              labelText: 'Iterations',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Key length
          DropdownButtonFormField<int>(
            key: ValueKey(
              'generator_key_length_${state.keyLengthBytes}',
            ),
            initialValue: state.keyLengthBytes,
            decoration: const InputDecoration(
              labelText: 'Key Length',
              suffixText: 'bytes',
              border: OutlineInputBorder(),
            ),
            items: const [16, 32, 64].map((length) {
              return DropdownMenuItem<int>(
                value: length,
                child: Text(
                  '$length bytes (${length * 8} bits)',
                ),
              );
            }).toList(),
            onChanged: state.isGenerating
                ? null
                : (value) {
              if (value != null) {
                notifier.updateKeyLength(value);
              }
            },
          ),
          const SizedBox(height: 24),

          // Error message
          if (state.generatorError != null) ...[
            Text(
              state.generatorError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Generate and Reset buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isGenerating
                      ? null
                      : notifier.generateHash,
                  icon: state.isGenerating
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.key),
                  label: Text(
                    state.isGenerating
                        ? 'Generating...'
                        : 'Generate Hash',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: state.isGenerating
                    ? null
                    : () {
                  notifier.resetGenerator();

                  final salt =
                      ref.read(pbkdf2GeneratorProvider).salt;

                  _updateSaltField(salt);
                },
                child: const Text('Reset'),
              ),
            ],
          ),

          // Generated derived key
          if (state.generatedHash != null) ...[
            const SizedBox(height: 28),
            Text(
              'Generated Derived Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    state.generatedHash!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final hash = state.generatedHash;
                      if (hash == null) return;

                      await Clipboard.setData(
                        ClipboardData(text: hash),
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Derived key copied to clipboard',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Output'),
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
