import 'package:flutter/material.dart';

/// Standardized spacing constants for consistent breathing room across the app.
abstract final class AppSpacing {
  /// Main screen body padding (was 16).
  static const double screenPadding = 20.0;

  /// Gap between peer-level cards (was 14).
  static const double cardGap = 18.0;

  /// Gap between logical sections / groups of cards.
  static const double sectionGap = 28.0;

  /// Padding inside most card containers.
  static const double innerCardPadding = 16.0;

  /// Tight gap for closely related elements.
  static const double tightGap = 10.0;

  /// Standard screen body padding as EdgeInsets.
  static const EdgeInsets screenInsets = EdgeInsets.symmetric(
    horizontal: screenPadding,
    vertical: screenPadding,
  );
}
