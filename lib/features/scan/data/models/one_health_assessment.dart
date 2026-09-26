enum VectorRiskLevel {
  low,
  moderate,
  critical,
}

enum HumanWellbeingRiskLevel {
  minimal,
  elevated,
  severe,
}

class OneHealthAssessment {
  final String id;
  final DateTime timestamp;
  final String locationSector;
  final double latitude;
  final double longitude;
  final double temperatureCelsius;
  final double relativeHumidityPercent;

  // Pillar 1: Ecosystem Integrity
  final double ecosystemIntegrityScore; // 0 - 100
  final String ecosystemSummary;

  // Pillar 2: Vector Proliferation
  final VectorRiskLevel vectorRisk;
  final double vectorOutbreakProbability; // 0.0 - 1.0
  final String vectorSummary;

  // Pillar 3: Human Well-being & Municipal Action
  final HumanWellbeingRiskLevel humanWellbeingRisk;
  final String municipalActionRecommendation;
  final String plainLanguageExplanation;

  // Raw Diagnostic Backing
  final double peakFrequencyHz;
  final bool mosquitoHarmonicDetected;
  final double yamnetInsectConfidence;
  final bool citizenConfirmedStandingWater;
  final String bankCondition;
  final bool isMarkedFalsePositive;

  const OneHealthAssessment({
    required this.id,
    required this.timestamp,
    required this.locationSector,
    required this.latitude,
    required this.longitude,
    required this.temperatureCelsius,
    required this.relativeHumidityPercent,
    required this.ecosystemIntegrityScore,
    required this.ecosystemSummary,
    required this.vectorRisk,
    required this.vectorOutbreakProbability,
    required this.vectorSummary,
    required this.humanWellbeingRisk,
    required this.municipalActionRecommendation,
    required this.plainLanguageExplanation,
    required this.peakFrequencyHz,
    required this.mosquitoHarmonicDetected,
    required this.yamnetInsectConfidence,
    required this.citizenConfirmedStandingWater,
    required this.bankCondition,
    required this.isMarkedFalsePositive,
  });

  String get vectorRiskLabel {
    switch (vectorRisk) {
      case VectorRiskLevel.low:
        return 'Low Proliferation Risk';
      case VectorRiskLevel.moderate:
        return 'Moderate Breeding Potential';
      case VectorRiskLevel.critical:
        return 'Critical Vector Outbreak Hazard';
    }
  }

  String get humanRiskLabel {
    switch (humanWellbeingRisk) {
      case HumanWellbeingRiskLevel.minimal:
        return 'Low Public Health Threat';
      case HumanWellbeingRiskLevel.elevated:
        return 'Elevated Urban Arbovirus Risk';
      case HumanWellbeingRiskLevel.severe:
        return 'Severe Epidemic Exposure Risk';
    }
  }
}
