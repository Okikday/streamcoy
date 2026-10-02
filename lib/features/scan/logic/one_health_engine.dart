import 'dart:math';
import '../data/models/spectral_analysis_result.dart';
import '../data/models/yamnet_result.dart';
import '../data/models/hitl_validation_data.dart';
import '../data/models/one_health_assessment.dart';
import '../data/models/audio_scan_scenario.dart';

class OneHealthEngine {
  /// Synthesizes acoustic DSP, YAMNet inferences, environmental context,
  /// and Human-in-the-Loop citizen observations into the 3-pillar One Health assessment.
  static OneHealthAssessment synthesizeAssessment({
    required SpectralAnalysisResult spectral,
    required YamnetResult yamnet,
    required HitlValidationData hitl,
    required AudioScanScenario scenario,
    required double tiltDegrees,
    double temperatureCelsius = 24.5,
    double relativeHumidityPercent = 78.0,
  }) {
    final now = DateTime.now();
    final assessmentId = 'streamcoy-obs-${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.millisecondsSinceEpoch.toString().substring(7)}';

    // -------------------------------------------------------------
    // PILLAR 1: Ecosystem Integrity Score (0 - 100)
    // -------------------------------------------------------------
    // Base components:
    // a) Flowing water presence (0-35 pts)
    final waterPoints = (yamnet.flowingWaterProbability * 35.0).clamp(0.0, 35.0);

    // b) Bioacoustic Index & Amphibian Presence (0-40 pts)
    final biFactor = (spectral.bioacousticIndex / 2.0).clamp(0.0, 1.0);
    final frogFactor = yamnet.amphibianFrogProbability;
    final biophonyPoints = ((biFactor * 0.6 + frogFactor * 0.4) * 40.0).clamp(0.0, 40.0);

    // c) Bank morphology & stability (0-25 pts)
    double bankPoints;
    switch (hitl.bankMorphology) {
      case BankMorphology.naturalVegetated:
        bankPoints = 25.0;
        break;
      case BankMorphology.moderateSlope:
        bankPoints = 16.0;
        break;
      case BankMorphology.steepArtificial:
        bankPoints = 6.0;
        break;
    }

    // Penalize heavy anthropic rumble
    final penalty = (yamnet.anthropicVehicleProbability * 20.0);
    final rawEcoScore = (waterPoints + biophonyPoints + bankPoints - penalty).clamp(0.0, 100.0);
    final ecosystemScore = (rawEcoScore * 10).round() / 10.0;

    String ecosystemSummary;
    if (ecosystemScore >= 75.0) {
      ecosystemSummary =
          'High Ecological Integrity: Robust riparian biophony, active aeration, natural vegetated buffer.';
    } else if (ecosystemScore >= 45.0) {
      ecosystemSummary =
          'Moderate Ecological Stress: Intermittent stream flow with localized pool stagnation and reduced biophony.';
    } else {
      ecosystemSummary =
          'Severe Eutrophication & Degradation: Artificial bank modification, heavy anthropic rumble, suppressed aquatic biophony.';
    }

    // -------------------------------------------------------------
    // PILLAR 2: Vector Proliferation Index (Low / Moderate / Critical)
    // -------------------------------------------------------------
    var vectorScore = 0.0;

    // Harmonic peak in 450-650 Hz
    if (spectral.isVectorBandPeak && !hitl.isFalsePositiveOverride) {
      vectorScore += 0.45;
      vectorScore += (spectral.peakProminence / 10.0).clamp(0.0, 0.15);
    }

    // YAMNet mosquito confidence
    if (!hitl.isFalsePositiveOverride) {
      vectorScore += yamnet.mosquitoProbability * 0.25;
    }

    // Citizen visual sighting of standing water or swarms
    if (hitl.visualSighting == VisualSightingStatus.yesStandingWater) {
      vectorScore += 0.25;
    } else if (hitl.visualSighting == VisualSightingStatus.unclear) {
      vectorScore += 0.10;
    }

    // Ambient humidity (> 65% is optimal vector breeding condition)
    if (relativeHumidityPercent > 65.0) {
      vectorScore += 0.10;
    }

    // False-positive override drops vector score significantly
    if (hitl.isFalsePositiveOverride) {
      vectorScore = min(vectorScore, 0.15);
    }

    final vectorProbability = (vectorScore).clamp(0.05, 0.96);

    VectorRiskLevel vectorRisk;
    String vectorSummary;
    if (vectorProbability >= 0.70) {
      vectorRisk = VectorRiskLevel.critical;
      vectorSummary =
          'Critical Vector Outbreak Potential: Narrow-band wingbeat resonance detected alongside confirmed stagnant breeding pools and high humidity.';
    } else if (vectorProbability >= 0.40) {
      vectorRisk = VectorRiskLevel.moderate;
      vectorSummary =
          'Moderate Vector Activity: Sub-critical acoustic indicators with potential micro-habitats in slow-moving stream sectors.';
    } else {
      vectorRisk = VectorRiskLevel.low;
      vectorSummary =
          'Low Vector Proliferation: Continuous water velocity, low wingbeat harmonic detection, active predatory amphibians.';
    }

    // -------------------------------------------------------------
    // PILLAR 3: Human Well-being & Municipal Action Rating
    // -------------------------------------------------------------
    HumanWellbeingRiskLevel humanRisk;
    String municipalAction;
    String plainExplanation;

    if (vectorRisk == VectorRiskLevel.critical) {
      humanRisk = HumanWellbeingRiskLevel.severe;
      municipalAction =
          'URGENT: Municipal Vector Control Alert dispatched. Targeted application of biological larvicide (Bacillus thuringiensis israelensis - Bti) recommended within 72 hours. Clear blockages causing standing water.';
      plainExplanation =
          'The audio sensor identified a sharp persistent energy peak at ${spectral.peakFrequencyHz.toStringAsFixed(1)} Hz, characteristic of mosquito flight frequencies. Combined with your confirmation of standing water and warm humid weather, this sector poses high risk for arbovirus transmission (West Nile / Dengue).';
    } else if (vectorRisk == VectorRiskLevel.moderate) {
      humanRisk = HumanWellbeingRiskLevel.elevated;
      municipalAction =
          'PRIORITY: Schedule municipal riparian inspection within 7 days. Monitor stream-bank micro-pools and consider vegetation thinning to promote natural water movement.';
      plainExplanation =
          'Acoustic energy indicates moderate insect activity with sporadic standing water pockets. Proactive stream-bank maintenance will prevent vector escalation.';
    } else {
      humanRisk = HumanWellbeingRiskLevel.minimal;
      municipalAction =
          'ROUTINE: Routine seasonal surveillance. Maintain natural riparian buffer and preserve amphibian breeding micro-refugia.';
      plainExplanation =
          'The stream exhibits healthy dynamic acoustics with active flow and amphibian biophony. No significant vector wingbeat spikes detected.';
    }

    return OneHealthAssessment(
      id: assessmentId,
      timestamp: now,
      locationSector: scenario.locationSector,
      latitude: 40.2056,
      longitude: -8.4195,
      temperatureCelsius: temperatureCelsius,
      relativeHumidityPercent: relativeHumidityPercent,
      ecosystemIntegrityScore: ecosystemScore,
      ecosystemSummary: ecosystemSummary,
      vectorRisk: vectorRisk,
      vectorOutbreakProbability: vectorProbability,
      vectorSummary: vectorSummary,
      humanWellbeingRisk: humanRisk,
      municipalActionRecommendation: municipalAction,
      plainLanguageExplanation: plainExplanation,
      peakFrequencyHz: spectral.peakFrequencyHz,
      mosquitoHarmonicDetected: spectral.isVectorBandPeak && !hitl.isFalsePositiveOverride,
      yamnetInsectConfidence: yamnet.insectProbability,
      citizenConfirmedStandingWater:
          hitl.visualSighting == VisualSightingStatus.yesStandingWater,
      bankCondition: hitl.bankMorphology.label,
      isMarkedFalsePositive: hitl.isFalsePositiveOverride,
    );
  }
}
