import 'package:flutter/material.dart';

/// Constrains content to a comfortable reading width on wide screens.
///
/// On narrow devices (< [maxWidth]), this is transparent — full width.
/// On wide screens (web/desktop), content is centered with a max width
/// and subtle side gutters for a polished look.
class ResponsiveBody extends StatelessWidget {
  final Widget child;

  /// Maximum content width. 540 is optimal for mobile-style single-column.
  final double maxWidth;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 540,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
