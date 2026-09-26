import 'package:flutter/material.dart';

class TiltGaugeWidget extends StatelessWidget {
  final double tiltDegrees;
  final ValueChanged<double>? onTiltChanged;

  const TiltGaugeWidget({
    super.key,
    required this.tiltDegrees,
    this.onTiltChanged,
  });

  bool get isOptimal => tiltDegrees >= 15.0 && tiltDegrees <= 45.0;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (tiltDegrees < 15.0) {
      statusColor = const Color(0xFFFFB300);
      statusText = 'Too Flat';
      statusIcon = Icons.arrow_downward_rounded;
    } else if (tiltDegrees <= 45.0) {
      statusColor = const Color(0xFF00E676);
      statusText = 'Optimal Riparian Sighting';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = const Color(0xFFFF9100);
      statusText = 'Too Steep';
      statusIcon = Icons.arrow_upward_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOptimal
              ? statusColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.screen_rotation_rounded,
                      color: Colors.white.withValues(alpha: 0.8), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Riparian Bank Incline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${tiltDegrees.toStringAsFixed(0)}° [$statusText]',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Visual Incline Bar with dynamic target green zone
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final targetStart = (15.0 / 90.0) * width;
              final targetWidth = (30.0 / 90.0) * width;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Target Green Zone
                  Positioned(
                    left: targetStart,
                    child: Container(
                      height: 10,
                      width: targetWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Interactive Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: statusColor,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: statusColor,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(
                      value: tiltDegrees,
                      min: 0.0,
                      max: 90.0,
                      onChanged: onTiltChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInclineLabel('0° (Flat)'),
              _buildInclineLabel('Target Zone (15° - 45°)'),
              _buildInclineLabel('90° (Vertical)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInclineLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 9,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
