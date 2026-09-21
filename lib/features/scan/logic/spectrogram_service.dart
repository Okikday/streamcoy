import 'dart:math';
import 'fft.dart';

List<double> _hanningWindow(int n) {
  return List.generate(n, (i) => 0.5 * (1 - cos(2 * pi * i / (n - 1))));
}

/// Compute a spectrogram (list of magnitude arrays) from raw PCM samples.
/// frameSize should be a power of two (e.g., 1024 or 2048). hopSize is typically frameSize~/2.
List<List<double>> computeSpectrogram(
  List<double> samples, {
  int frameSize = 1024,
  int hopSize = 512,
}) {
  final window = _hanningWindow(frameSize);
  final frames = <List<double>>[];
  for (var start = 0; start + frameSize <= samples.length; start += hopSize) {
    final frame = List<double>.generate(
      frameSize,
      (i) => samples[start + i] * window[i],
    );
    final mags = fftMagnitudes(frame);
    frames.add(mags);
  }
  return frames;
}

/// Quick detection of prominent peak within a frequency band given sampleRate and frameSize.
double detectPeakFrequency(
  List<double> magnitudes,
  int sampleRate,
  int frameSize,
) {
  final maxIdx = magnitudes.indexWhere((m) => m == magnitudes.reduce(max));
  final freqRes = sampleRate / frameSize;
  return maxIdx * freqRes;
}
