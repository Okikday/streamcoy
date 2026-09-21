import 'package:flutter/material.dart';

/// Minimal UI helpers used by features (to keep widgets declarative).
class UiUtils {
  static void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
