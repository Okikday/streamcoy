import 'package:flutter/material.dart';
import 'spectrogram_painter.dart';

class SpectrogramWidget extends StatefulWidget {
  final List<List<double>> frames;
  final bool isVectorDetected;
  final double peakFrequencyHz;
  final double height;

  const SpectrogramWidget({
    super.key,
    required this.frames,
    required this.isVectorDetected,
    required this.peakFrequencyHz,
    this.height = 220,
  });

  @override
  State<SpectrogramWidget> createState() => _SpectrogramWidgetState();
}

class _SpectrogramWidgetState extends State<SpectrogramWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF070D18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isVectorDetected
              ? const Color(0xFFFF5252).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.12),
          width: widget.isVectorDetected ? 1.8 : 1.0,
        ),
        boxShadow: [
          if (widget.isVectorDetected)
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Heatmap Canvas
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: SpectrogramPainter(
                  frames: widget.frames,
                  maxFrequencyHz: 4000.0,
                  highlightMosquitoBand: widget.isVectorDetected,
                  peakFrequencyHz: widget.peakFrequencyHz,
                  animationPhase: _animCtrl.value,
                ),
              );
            },
          ),

          // Top Badge: Status / Track 3 Compliance
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isVectorDetected
                    ? const Color(0xFFFF5252).withValues(alpha: 0.9)
                    : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isVectorDetected
                      ? const Color(0xFFFF8A80)
                      : const Color(0xFF00E5FF),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isVectorDetected
                        ? Icons.warning_amber_rounded
                        : Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.isVectorDetected
                        ? 'SPIKE: ${widget.peakFrequencyHz.toStringAsFixed(0)} Hz (Culicidae Band)'
                        : 'Biophony Scan (0 - 4 kHz)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Time Axis Guide
          Positioned(
            bottom: 4,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLabel('0s'),
                _buildTimeLabel('10s'),
                _buildTimeLabel('20s'),
                _buildTimeLabel('30s (PCM Buffer)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 9,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
