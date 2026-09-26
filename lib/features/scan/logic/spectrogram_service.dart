import 'dart:math';
import 'fft.dart';

/// Service generating time-frequency frames for the Spectrogram Heatmap.
class SpectrogramService {
  /// Computes a list of magnitude frames from raw PCM audio samples.
  /// Each frame is of length [maxFrequencyBins], representing frequencies from 0 Hz up to targetMaxHz.
  static List<List<double>> computeSpectrogram(
    List<double> samples, {
    int frameSize = 1024,
    int hopSize = 512,
    double sampleRate = 16000.0,
    double targetMaxHz = 4000.0,
  }) {
    if (samples.length < frameSize) {
      return [];
    }

    final frames = <List<double>>[];
    final binWidth = sampleRate / frameSize;
    final maxBin = min(frameSize ~/ 2, (targetMaxHz / binWidth).ceil());

    for (var start = 0; start + frameSize <= samples.length; start += hopSize) {
      final slice = samples.sublist(start, start + frameSize);
      final windowed = FftEngine.applyHanningWindow(slice);
      final mags = FftEngine.computeMagnitudes(windowed);

      // Keep only up to targetMaxHz (e.g. 4000 Hz) to optimize UI rendering and focus on bioacoustics
      final truncatedMags = mags.sublist(0, min(maxBin, mags.length));
      frames.add(truncatedMags);
    }

    return frames;
  }
}
