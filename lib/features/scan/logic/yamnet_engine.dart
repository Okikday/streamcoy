import 'dart:math';
import '../data/models/spectral_analysis_result.dart';
import '../data/models/yamnet_result.dart';
import '../data/models/audio_scan_scenario.dart';

/// On-device neural classifier simulating YAMNet MobileNet-v1 acoustic inference.
class YamnetEngine {
  /// Evaluates acoustic spectral features and maps them to target AudioSet sound classes.
  static YamnetResult classifyAudio({
    required List<double> samples,
    required SpectralAnalysisResult spectral,
    required AudioScanScenario scenario,
  }) {
    if (samples.isEmpty) {
      return YamnetResult.empty();
    }

    // 1. Insect (ID: 125) & Mosquito (ID: 130)
    double insectProb;
    double mosquitoProb;

    if (spectral.isVectorBandPeak) {
      final factor = (spectral.peakProminence / 8.0).clamp(0.65, 0.94);
      mosquitoProb = factor;
      insectProb = min(0.96, factor + 0.05);
    } else if (scenario.hasMosquitoHarmonic) {
      mosquitoProb = 0.76;
      insectProb = 0.83;
    } else {
      mosquitoProb = 0.04;
      insectProb = (spectral.bioacousticIndex > 1.2) ? 0.42 : 0.12;
    }

    // 2. Frog / Amphibians (ID: 136)
    double frogProb;
    if (scenario.frogCallEnergy > 0.4) {
      frogProb = 0.88;
    } else if (spectral.bioacousticIndex > 1.5 && !spectral.isVectorBandPeak) {
      frogProb = 0.72;
    } else if (spectral.bioacousticIndex > 0.8) {
      frogProb = 0.28;
    } else {
      frogProb = 0.05;
    }

    // 3. Water / Flowing stream (ID: 290)
    double waterProb;
    if (scenario.waterFlowEnergy > 0.6) {
      waterProb = 0.91;
    } else if (scenario.waterFlowEnergy > 0.2) {
      waterProb = 0.45;
    } else {
      waterProb = 0.18;
    }

    // 4. Vehicle / Anthropic rumble (ID: 300)
    double vehicleProb;
    if (scenario.urbanNoiseEnergy > 0.5) {
      vehicleProb = 0.86;
    } else if (spectral.anthropophonyEnergy > spectral.biophonyEnergy * 2.0) {
      vehicleProb = 0.68;
    } else {
      vehicleProb = 0.09;
    }

    // Determine top class
    final scores = {
      'Mosquito (Culicidae wingbeat)': mosquitoProb,
      'Insect (General biophony)': insectProb,
      'Amphibian / Frog': frogProb,
      'Flowing Water (Riparian)': waterProb,
      'Anthropic Vehicle Rumble': vehicleProb,
    };

    var topClass = 'None';
    var topScore = 0.0;
    scores.forEach((label, score) {
      if (score > topScore) {
        topScore = score;
        topClass = label;
      }
    });

    return YamnetResult(
      insectProbability: insectProb,
      mosquitoProbability: mosquitoProb,
      amphibianFrogProbability: frogProb,
      flowingWaterProbability: waterProb,
      anthropicVehicleProbability: vehicleProb,
      topClassLabel: topClass,
      topConfidence: topScore,
    );
  }
}
