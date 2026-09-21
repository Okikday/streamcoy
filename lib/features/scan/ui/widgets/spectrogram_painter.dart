import 'package:flutter/material.dart';

class SpectrogramPainter extends CustomPainter {
  final List<List<double>> frames;

  SpectrogramPainter(this.frames);

  @override
  void paint(Canvas canvas, Size size) {
    if (frames.isEmpty) return;
    final paint = Paint();
    final frameCount = frames.length;
    final binCount = frames[0].length;
    final pixelPerFrame = size.width / frameCount;
    final pixelPerBin = size.height / binCount;
    final maxVal = frames.expand((f) => f).reduce((a, b) => a > b ? a : b);
    for (var x = 0; x < frameCount; x++) {
      final frame = frames[x];
      for (var y = 0; y < binCount; y++) {
        final v = frame[y] / (maxVal == 0 ? 1 : maxVal);
        final rect = Rect.fromLTWH(
          x * pixelPerFrame,
          size.height - (y + 1) * pixelPerBin,
          pixelPerFrame,
          pixelPerBin,
        );
        paint.color =
            Color.lerp(Colors.black, Colors.yellow, v) ?? Colors.black;
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpectrogramPainter oldDelegate) =>
      oldDelegate.frames != frames;
}
