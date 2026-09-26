import 'dart:math';
import 'package:flutter/material.dart';

class SpectrogramPainter extends CustomPainter {
  final List<List<double>> frames;
  final double maxFrequencyHz;
  final bool highlightMosquitoBand;
  final double peakFrequencyHz;
  final double animationPhase;

  SpectrogramPainter({
    required this.frames,
    this.maxFrequencyHz = 4000.0,
    this.highlightMosquitoBand = false,
    this.peakFrequencyHz = 542.0,
    this.animationPhase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background canvas
    final bgPaint = Paint()..color = const Color(0xFF070D18);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (frames.isEmpty) {
      _paintEmptyState(canvas, size);
      return;
    }

    final frameCount = frames.length;
    final binCount = frames[0].length;
    final pixelPerFrame = size.width / frameCount;
    final pixelPerBin = size.height / binCount;

    // Find dynamic maximum for robust normalization
    var maxVal = 0.0001;
    for (final frame in frames) {
      for (final v in frame) {
        if (v > maxVal) maxVal = v;
      }
    }

    final cellPaint = Paint()..style = PaintingStyle.fill;

    // Draw Heatmap cells
    for (var x = 0; x < frameCount; x++) {
      final frame = frames[x];
      final currentX = x * pixelPerFrame;

      for (var y = 0; y < binCount; y++) {
        final rawVal = frame[y];
        final norm = (rawVal / maxVal).clamp(0.0, 1.0);
        final color = _getThermalColor(norm);

        cellPaint.color = color;
        final rect = Rect.fromLTWH(
          currentX,
          size.height - (y + 1) * pixelPerBin,
          pixelPerFrame + 0.5,
          pixelPerBin + 0.5,
        );
        canvas.drawRect(rect, cellPaint);
      }
    }

    // Draw Vector Critical Band (450 - 650 Hz) Highlight if detected
    if (highlightMosquitoBand) {
      _paintVectorCriticalBand(canvas, size, maxFrequencyHz);
    }

    // Frequency Grid & Axis Guides
    _paintFrequencyGrid(canvas, size, maxFrequencyHz);
  }

  void _paintVectorCriticalBand(
    Canvas canvas,
    Size size,
    double maxFreq,
  ) {
    final yTopNorm = (650.0 / maxFreq).clamp(0.0, 1.0);
    final yBottomNorm = (450.0 / maxFreq).clamp(0.0, 1.0);

    final topY = size.height * (1.0 - yTopNorm);
    final bottomY = size.height * (1.0 - yBottomNorm);
    final bandHeight = (bottomY - topY).abs();

    final bandRect = Rect.fromLTWH(0, topY, size.width, bandHeight);

    // Glowing highlight band
    final glowPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.22 + 0.08 * sin(animationPhase * 2 * pi))
      ..style = PaintingStyle.fill;
    canvas.drawRect(bandRect, glowPaint);

    // Border stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(bandRect, strokePaint);

    // Peak frequency dashed center line
    final peakYNorm = (peakFrequencyHz / maxFreq).clamp(0.0, 1.0);
    final peakY = size.height * (1.0 - peakYNorm);

    final linePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(0, peakY), Offset(size.width, peakY), linePaint);
  }

  void _paintFrequencyGrid(Canvas canvas, Size size, double maxFreq) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.70),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    // Key frequency lines: 4000 Hz, 2000 Hz, 550 Hz
    final markers = [4000.0, 2000.0, 1000.0, 550.0];
    for (final freq in markers) {
      if (freq <= maxFreq) {
        final norm = freq / maxFreq;
        final y = size.height * (1.0 - norm);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

        final label = freq >= 1000
            ? '${(freq / 1000).toStringAsFixed(0)} kHz'
            : '${freq.toInt()} Hz';
        final textSpan = TextSpan(text: label, style: textStyle);
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(6, y - tp.height - 2));
      }
    }
  }

  void _paintEmptyState(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: 'Awaiting 16 kHz Stream Acoustic Input...',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2,
      ),
    );
  }

  /// Thermal Colormap: Dark Navy -> Purple -> Magenta -> Orange -> Electric Yellow
  Color _getThermalColor(double value) {
    if (value <= 0.02) return const Color(0xFF070D18);
    if (value < 0.25) {
      final t = value / 0.25;
      return Color.lerp(const Color(0xFF0D1B2A), const Color(0xFF4A148C), t)!;
    } else if (value < 0.50) {
      final t = (value - 0.25) / 0.25;
      return Color.lerp(const Color(0xFF4A148C), const Color(0xFFD81B60), t)!;
    } else if (value < 0.75) {
      final t = (value - 0.50) / 0.25;
      return Color.lerp(const Color(0xFFD81B60), const Color(0xFFFF9100), t)!;
    } else {
      final t = (value - 0.75) / 0.25;
      return Color.lerp(const Color(0xFFFF9100), const Color(0xFFFFFF00), t)!;
    }
  }

  @override
  bool shouldRepaint(covariant SpectrogramPainter oldDelegate) {
    return oldDelegate.frames != frames ||
        oldDelegate.highlightMosquitoBand != highlightMosquitoBand ||
        oldDelegate.peakFrequencyHz != peakFrequencyHz ||
        oldDelegate.animationPhase != animationPhase;
  }
}
