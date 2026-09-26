import 'package:flutter/material.dart';
import 'scan_screen.dart';

export 'scan_screen.dart';

/// Legacy bridge widget for ScanView.
class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      onProceedToAnalysis: () {
        Navigator.of(context).pop();
      },
    );
  }
}
