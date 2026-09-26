import 'dart:math';
import '../data/models/spectral_analysis_result.dart';
import 'fft.dart';

class SpectralEngine {
  /// Evaluates an audio buffer and returns full spectral metrics.
  static SpectralAnalysisResult analyzeBuffer(
    List<double> rawSamples, {
    double sampleRate = 16000.0,
    int fftSize = 1024,
  }) {
    if (rawSamples.isEmpty) {
      return SpectralAnalysisResult.empty();
    }

    // 1. High-pass filter (>150 Hz) to eliminate wind turbulence & vehicle rumble
    final filtered = FftEngine.applyHighPassFilter(
      rawSamples,
      sampleRate: sampleRate,
      cutoffHz: 150.0,
    );

    // 2. Extract representative slice for fine spectral resolution (last 2048 or 1024 samples)
    final sliceLen = (rawSamples.length >= 2048) ? 2048 : 1024;
    final startIndex = max(0, filtered.length - sliceLen);
    final slice = filtered.sublist(startIndex, startIndex + sliceLen);

    // 3. Windowed FFT
    final windowed = FftEngine.applyHanningWindow(slice);
    final magnitudes = FftEngine.computeMagnitudes(windowed);
    final binWidth = sampleRate / sliceLen; // e.g. 16000 / 2048 = 7.8125 Hz

    // 4. Power Spectral Density S(f) = |X(f)|^2
    final psd = magnitudes.map((m) => m * m).toList();

    // 5. Search for peak in Vector Critical Band (450 - 650 Hz) and overall
    final minBinVector = (450.0 / binWidth).floor().clamp(0, magnitudes.length - 1);
    final maxBinVector = (650.0 / binWidth).ceil().clamp(0, magnitudes.length - 1);

    var maxVectorMag = 0.0;
    var maxVectorBin = minBinVector;
    for (var i = minBinVector; i <= maxBinVector; i++) {
      if (magnitudes[i] > maxVectorMag) {
        maxVectorMag = magnitudes[i];
        maxVectorBin = i;
      }
    }

    // Overall peak
    var overallMaxMag = 0.0;
    var overallMaxBin = 0;
    for (var i = 1; i < magnitudes.length; i++) {
      if (magnitudes[i] > overallMaxMag) {
        overallMaxMag = magnitudes[i];
        overallMaxBin = i;
      }
    }

    // Compute average magnitude across spectrum for peak-to-average ratio (Q-factor)
    final avgMagnitude =
        magnitudes.reduce((a, b) => a + b) / (magnitudes.isNotEmpty ? magnitudes.length : 1);
    final prominence = (avgMagnitude > 0) ? (maxVectorMag / avgMagnitude) : 0.0;

    // Vector peak is considered detected if prominence in 450-650 Hz is significant
    final isVectorDetected = prominence > 2.5 && maxVectorMag > 0.04;
    final peakFrequencyHz = (isVectorDetected
            ? maxVectorBin
            : overallMaxBin) *
        binWidth;

    // 6. Compute Bioacoustic Index (BI):
    // BI = integral_{2000}^{8000} S(f) df / integral_{0}^{1500} S(f) df
    final bin1500 = (1500.0 / binWidth).clamp(0, psd.length - 1).toInt();
    final bin2000 = (2000.0 / binWidth).clamp(0, psd.length - 1).toInt();
    final bin8000 = (8000.0 / binWidth).clamp(0, psd.length - 1).toInt();

    var anthropoSum = 0.0; // 0 - 1500 Hz
    for (var i = 0; i <= bin1500; i++) {
      anthropoSum += psd[i];
    }

    var biophonySum = 0.0; // 2000 - 8000 Hz
    for (var i = bin2000; i <= bin8000; i++) {
      biophonySum += psd[i];
    }

    // Vector critical band energy (450 - 650 Hz)
    var vectorBandEnergy = 0.0;
    for (var i = minBinVector; i <= maxBinVector; i++) {
      vectorBandEnergy += psd[i];
    }
    final totalEnergy = psd.fold(0.0, (a, b) => a + b);
    final vectorRatio = totalEnergy > 0 ? (vectorBandEnergy / totalEnergy) : 0.0;

    final bi = anthropoSum > 0 ? (biophonySum / anthropoSum) : 1.0;

    // Generate downsampled power spectrum summary for UI mini-charts (32 bins)
    final summaryBins = 32;
    final chunkSize = max(1, magnitudes.length ~/ summaryBins);
    final powerSummary = <double>[];
    for (var i = 0; i < summaryBins; i++) {
      var chunkSum = 0.0;
      final start = i * chunkSize;
      final end = min(magnitudes.length, start + chunkSize);
      for (var j = start; j < end; j++) {
        chunkSum += magnitudes[j];
      }
      powerSummary.add(chunkSum / (end - start));
    }

    return SpectralAnalysisResult(
      peakFrequencyHz: peakFrequencyHz,
      peakMagnitude: isVectorDetected ? maxVectorMag : overallMaxMag,
      peakProminence: prominence,
      isVectorBandPeak: isVectorDetected,
      vectorBandEnergyRatio: vectorRatio,
      bioacousticIndex: bi,
      anthropophonyEnergy: anthropoSum,
      biophonyEnergy: biophonySum,
      totalSamplesProcessed: rawSamples.length,
      sampleRate: sampleRate,
      powerSpectrumSummary: powerSummary,
    );
  }
}
