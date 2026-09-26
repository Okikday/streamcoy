import 'dart:math';
import 'package:flutter/material.dart';

class WaveformVisualizer extends StatelessWidget {
  final List<double> waveformSamples;
  final bool isRecording;
  final int currentSamples;
  final int totalSamples;

  const WaveformVisualizer({
    super.key,
    required this.waveformSamples,
    required this.isRecording,
    required this.currentSamples,
    this.totalSamples = 480000,
  });

  @override
  Widget build(BuildContext context) {
    final bars = waveformSamples.isEmpty
        ? List.generate(48, (i) => 0.08 + 0.05 * sin(i * 0.4))
        : waveformSamples;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecording
              ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording
                        ? '16 kHz Raw Linear PCM Stream'
                        : 'Acoustic Sensor Standby',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Text(
                '${(currentSamples / 1000).toStringAsFixed(0)}k / ${(totalSamples / 1000).toStringAsFixed(0)}k samples',
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(bars.length, (index) {
                final val = bars[index].clamp(0.06, 1.0);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 3.2,
                  height: 52 * val,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF00B0FF),
                        isRecording
                            ? (val > 0.6
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00E5FF))
                            : const Color(0xFF00E676),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
