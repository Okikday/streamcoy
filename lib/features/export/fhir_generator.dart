import '../scan/data/models/one_health_assessment.dart';
import 'fhir_bundle_builder.dart';

export 'fhir_bundle_builder.dart';

/// Legacy bridge function for backward compatibility.
Map<String, dynamic> generateObservation({
  double? peakHz,
  required bool confirmed,
  required String bank,
}) {
  final now = DateTime.now();
  final dummy = OneHealthAssessment(
    id: 'echostream-obs-${now.millisecondsSinceEpoch}',
    timestamp: now,
    locationSector: 'Urban Stream Sector Alpha - Coimbra Corridor',
    latitude: 40.2056,
    longitude: -8.4195,
    temperatureCelsius: 24.5,
    relativeHumidityPercent: 78.0,
    ecosystemIntegrityScore: 42.0,
    ecosystemSummary: 'Moderate Eutrophication (Stagnant flow)',
    vectorRisk: (peakHz != null && peakHz >= 450 && peakHz <= 650)
        ? VectorRiskLevel.critical
        : VectorRiskLevel.low,
    vectorOutbreakProbability:
        (peakHz != null && peakHz >= 450 && peakHz <= 650) ? 0.84 : 0.12,
    vectorSummary: 'Bioacoustic Mosquito Vector Assessment',
    humanWellbeingRisk: (peakHz != null && peakHz >= 450 && peakHz <= 650)
        ? HumanWellbeingRiskLevel.severe
        : HumanWellbeingRiskLevel.minimal,
    municipalActionRecommendation:
        'Schedule municipal biocontrol and Bti application.',
    plainLanguageExplanation:
        'Acoustic spike identified matching Culicidae wingbeat harmonic profiles.',
    peakFrequencyHz: peakHz ?? 0.0,
    mosquitoHarmonicDetected:
        peakHz != null && peakHz >= 450 && peakHz <= 650,
    yamnetInsectConfidence: 0.82,
    citizenConfirmedStandingWater: confirmed,
    bankCondition: bank,
    isMarkedFalsePositive: false,
  );
  return FhirBundleBuilder.buildObservation(dummy);
}
