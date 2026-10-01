import 'package:flutter/material.dart';

/// A consistent styled card used across all screens.
///
/// Centralizes background color, border radius, border styling, and optional
/// accent color so changes propagate everywhere.
class SentinelCard extends StatelessWidget {
  final Widget child;

  /// Optional accent color for the card border.
  final Color? accentColor;

  /// Optional header widget shown above the [child] with a divider.
  final Widget? header;

  /// Override padding (defaults to 16).
  final EdgeInsetsGeometry? padding;

  const SentinelCard({
    super.key,
    required this.child,
    this.accentColor,
    this.header,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        accentColor?.withValues(alpha: 0.5) ??
        Colors.white.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14243D),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: header!,
            ),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
