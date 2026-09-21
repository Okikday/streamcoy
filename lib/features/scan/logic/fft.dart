import 'dart:math';

class Complex {
  final double re;
  final double im;
  const Complex(this.re, this.im);
  Complex operator +(Complex other) => Complex(re + other.re, im + other.im);
  Complex operator -(Complex other) => Complex(re - other.re, im - other.im);
  Complex operator *(Complex other) =>
      Complex(re * other.re - im * other.im, re * other.im + im * other.re);
  double abs() => sqrt(re * re + im * im);
}

List<Complex> _fftRecursive(List<Complex> x) {
  final n = x.length;
  if (n == 1) return [x[0]];
  if (n % 2 != 0) {
    // pad to next power of two
    final m = 1 << (log(n) / ln2).ceil();
    final padded = List<Complex>.from(x)
      ..addAll(List.filled(m - n, const Complex(0, 0)));
    return _fftRecursive(padded);
  }
  final even = List<Complex>.generate(n ~/ 2, (i) => x[2 * i]);
  final odd = List<Complex>.generate(n ~/ 2, (i) => x[2 * i + 1]);
  final fe = _fftRecursive(even);
  final fo = _fftRecursive(odd);
  final res = List<Complex>.filled(n, const Complex(0, 0));
  for (var k = 0; k < n ~/ 2; k++) {
    final t = Complex(cos(-2 * pi * k / n), sin(-2 * pi * k / n)) * fo[k];
    res[k] = fe[k] + t;
    res[k + n ~/ 2] = fe[k] - t;
  }
  return res;
}

/// Compute FFT magnitudes for a real input buffer. Returns list of magnitudes (length N/2).
List<double> fftMagnitudes(List<double> input) {
  final n = input.length;
  final complex = List<Complex>.generate(n, (i) => Complex(input[i], 0));
  final freq = _fftRecursive(complex);
  final half = n ~/ 2;
  return List<double>.generate(half, (i) => freq[i].abs());
}
