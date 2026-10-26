// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pbkdf2_generator_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Pbkdf2GeneratorNotifier)
final pbkdf2GeneratorProvider = Pbkdf2GeneratorNotifierProvider._();

final class Pbkdf2GeneratorNotifierProvider
    extends $NotifierProvider<Pbkdf2GeneratorNotifier, Pbkdf2State> {
  Pbkdf2GeneratorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pbkdf2GeneratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pbkdf2GeneratorNotifierHash();

  @$internal
  @override
  Pbkdf2GeneratorNotifier create() => Pbkdf2GeneratorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Pbkdf2State value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Pbkdf2State>(value),
    );
  }
}

String _$pbkdf2GeneratorNotifierHash() =>
    r'b4496561280b9fdecb6792b5fabd695211cbfe70';

abstract class _$Pbkdf2GeneratorNotifier extends $Notifier<Pbkdf2State> {
  Pbkdf2State build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Pbkdf2State, Pbkdf2State>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Pbkdf2State, Pbkdf2State>,
              Pbkdf2State,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
