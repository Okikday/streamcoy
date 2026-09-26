import 'dart:math';
import '../data/models/audio_scan_scenario.dart';

/// Generates realistic 16 kHz Mono Linear PCM audio streams for field simulation.
class AudioSynthesizer {
  final Random _rng = Random(42);

  // Pink noise state
  double _b0 = 0.0;
  double _b1 = 0.0;
  double _b2 = 0.0;

  /// Synthesize a 1-second block (16,000 samples) of audio data
  /// based on scenario characteristics.
  List<double> generateSecondBlock({
    required AudioScanScenario scenario,
    required int currentSecond,
    int sampleRate = 16000,
    double? customToneFreq,
  }) {
    final block = List<double>.filled(sampleRate, 0.0);
    final targetFreq = customToneFreq ?? scenario.dominantFrequency;

    for (var i = 0; i < sampleRate; i++) {
      final t = (currentSecond * sampleRate + i) / sampleRate;

      // 1. Water rushing component (pink/brownian filtered noise)
      final white = (_rng.nextDouble() * 2.0 - 1.0);
      _b0 = 0.99765 * _b0 + white * 0.0990460;
      _b1 = 0.96300 * _b1 + white * 0.2965164;
      _b2 = 0.57000 * _b2 + white * 1.0526913;
      final pink = (_b0 + _b1 + _b2 + white * 0.1848) * 0.05;
      final waterSample = pink * scenario.waterFlowEnergy * 2.0;

      // 2. Mosquito wingbeat tone (Narrow-band sine wave at ~542 Hz + faint harmonic at 2x)
      var mosquitoSample = 0.0;
      if (scenario.hasMosquitoHarmonic && targetFreq > 0) {
        // Slight micro-frequency modulation representing wing flutter
        final microMod = sin(2 * pi * 4.0 * t) * 3.0;
        final actualFreq = targetFreq + microMod;
        final fundamental = sin(2 * pi * actualFreq * t);
        final harmonic2 = 0.25 * sin(2 * pi * (actualFreq * 2) * t);
        mosquitoSample = (fundamental + harmonic2) * 0.35;
      }

      // 3. Amphibian / Frog periodic biophony (intermittent chirps ~1800-2400 Hz)
      var frogSample = 0.0;
      if (scenario.frogCallEnergy > 0) {
        // Frog call pulse every 1.5 seconds lasting 0.3 seconds
        final phase = t % 1.5;
        if (phase < 0.35) {
          final envelope = sin(pi * (phase / 0.35));
          frogSample = envelope *
              sin(2 * pi * 1950.0 * t) *
              scenario.frogCallEnergy *
              0.4;
        }
      }

      // 4. Urban traffic / vehicle low-frequency rumble (< 140 Hz)
      var urbanSample = 0.0;
      if (scenario.urbanNoiseEnergy > 0) {
        final rumble1 = sin(2 * pi * 65.0 * t);
        final rumble2 = sin(2 * pi * 115.0 * t) * 0.6;
        urbanSample =
            (rumble1 + rumble2) * scenario.urbanNoiseEnergy * 0.3;
      }

      // 5. Thermal noise floor
      final floorNoise = (_rng.nextDouble() * 2.0 - 1.0) * 0.02;

      // Combine and clamp to [-1.0, 1.0]
      final combined = waterSample +
          mosquitoSample +
          frogSample +
          urbanSample +
          floorNoise;

      block[i] = combined.clamp(-1.0, 1.0);
    }

    return block;
  }
}
