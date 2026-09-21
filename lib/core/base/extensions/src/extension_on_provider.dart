import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight provider helper extensions used across the project.
extension ProviderExt on Object {
  /// Read the provider from a non-widget [Ref].
  T readX<T>(Ref ref) => ref.read(this as dynamic) as T;

  /// Read the provider from a WidgetRef.
  T read<T>(WidgetRef ref) => ref.read(this as dynamic) as T;

  /// Watch the provider from a WidgetRef.
  T watch<T>(WidgetRef ref) => ref.watch(this as dynamic) as T;
}
