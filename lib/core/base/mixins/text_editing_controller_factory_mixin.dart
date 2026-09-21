import 'package:flutter/widgets.dart';

/// Mixin to create and manage `TextEditingController` instances inside Pods.
///
/// Usage:
/// - Call `useTextEditingController()` to create and register a controller.
/// - Call `disposeControllers()` during `ref.onDispose` to clean up.
mixin TextEditingControllerFactoryMixin {
  final List<TextEditingController> _tecRegistry = [];

  TextEditingController useTextEditingController({String? text}) {
    final c = TextEditingController(text: text);
    _tecRegistry.add(c);
    return c;
  }

  void disposeControllers() {
    for (final c in _tecRegistry) {
      try {
        c.dispose();
      } catch (_) {}
    }
    _tecRegistry.clear();
  }
}
