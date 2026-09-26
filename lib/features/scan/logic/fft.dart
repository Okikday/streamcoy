import 'dart:math';

/// High-performance Pure Dart FFT & DSP Engine for Bioacoustics.
class FftEngine {
  /// Applies a Hanning window to the time-domain signal.
  static List<double> applyHanningWindow(List<double> input) {
    final n = input.length;
    final windowed = List<double>.filled(n, 0.0);
    for (var i = 0; i < n; i++) {
      final w = 0.5 * (1.0 - cos(2.0 * pi * i / (n - 1)));
      windowed[i] = input[i] * w;
    }
    return windowed;
  }

  /// High-pass filter: Attenuates frequencies below cutoffHz (default 150 Hz)
  /// to eliminate wind turbulence and mechanical vehicle rumble.
  static List<double> applyHighPassFilter(
    List<double> samples, {
    double sampleRate = 16000.0,
    double cutoffHz = 150.0,
  }) {
    // 1st order recursive RC high-pass filter
    final rc = 1.0 / (2.0 * pi * cutoffHz);
    final dt = 1.0 / sampleRate;
    final alpha = rc / (rc + dt);

    final filtered = List<double>.filled(samples.length, 0.0);
    if (samples.isEmpty) return filtered;

    filtered[0] = samples[0];
    for (var i = 1; i < samples.length; i++) {
      filtered[i] = alpha * (filtered[i - 1] + samples[i] - samples[i - 1]);
    }
    return filtered;
  }

  /// Iterative Cooley-Tukey Radix-2 FFT in O(N log N).
  /// Requires input length N to be a power of 2.
  static List<double> computeMagnitudes(List<double> realInput) {
    final n = realInput.length;
    assert((n & (n - 1)) == 0, 'FFT size must be a power of two');

    final real = List<double>.from(realInput);
    final imag = List<double>.filled(n, 0.0);

    // Bit reversal permutation
    var j = 0;
    for (var i = 0; i < n - 1; i++) {
      if (i < j) {
        final tr = real[i];
        real[i] = real[j];
        real[j] = tr;

        final ti = imag[i];
        imag[i] = imag[j];
        imag[j] = ti;
      }
      var k = n >> 1;
      while (k <= j) {
        j -= k;
        k >>= 1;
      }
      j += k;
    }

    // Cooley-Tukey Butterfly computation
    for (var len = 2; len <= n; len <<= 1) {
      final halfLen = len >> 1;
      final angle = -2.0 * pi / len;
      final wStepReal = cos(angle);
      final wStepImag = sin(angle);

      for (var i = 0; i < n; i += len) {
        var wReal = 1.0;
        var wImag = 0.0;

        for (var k = 0; k < halfLen; k++) {
          final uReal = real[i + k];
          final uImag = imag[i + k];

          final vReal = real[i + k + halfLen] * wReal -
              imag[i + k + halfLen] * wImag;
          final vImag = real[i + k + halfLen] * wImag +
              imag[i + k + halfLen] * wReal;

          real[i + k] = uReal + vReal;
          imag[i + k] = uImag + vImag;

          real[i + k + halfLen] = uReal - vReal;
          imag[i + k + halfLen] = uImag - vImag;

          final nextWReal = wReal * wStepReal - wImag * wStepImag;
          final nextWImag = wReal * wStepImag + wImag * wStepReal;
          wReal = nextWReal;
          wImag = nextWImag;
        }
      }
    }

    // Return single-sided magnitude spectrum (length N / 2)
    final half = n ~/ 2;
    final magnitudes = List<double>.filled(half, 0.0);
    for (var i = 0; i < half; i++) {
      magnitudes[i] = sqrt(real[i] * real[i] + imag[i] * imag[i]) / half;
    }
    return magnitudes;
  }
}
