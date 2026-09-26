import 'dart:convert';
import '../scan/data/models/one_health_assessment.dart';

/// HL7 FHIR R4 Interoperability Generator (Track 7 Alignment).
class FhirBundleBuilder {
  /// Generates a compliant HL7 FHIR R4 Observation resource map.
  static Map<String, dynamic> buildObservation(OneHealthAssessment assessment) {
    return {
      'resourceType': 'Observation',
      'id': assessment.id,
      'meta': {
        'profile': [
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-observation',
          'http://oneaquahealth.eu/fhir/StructureDefinition/urban-stream-sentinel',
        ],
        'lastUpdated': assessment.timestamp.toUtc().toIso8601String(),
      },
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'survey',
              'display': 'Survey',
            },
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'vital-signs',
              'display': 'Environmental Vital Sign',
            },
          ],
        },
      ],
      'code': {
        'coding': [
          {
            'system': 'http://loinc.org',
            'code': '96608-5',
            'display': 'Environmental health and risk assessment panel',
          },
          {
            'system': 'http://snomed.info/sct',
            'code': '429892002',
            'display': 'Mosquito-borne disease risk assessment (procedure)',
          },
        ],
        'text': 'EchoStream One Health Assessment',
      },
      'subject': {
        'display': assessment.locationSector,
        'type': 'Location',
      },
      'performer': [
        {
          'display': 'Elena (Citizen Scientist Sentinel #EU-7429)',
          'type': 'Practitioner',
        },
      ],
      'effectiveDateTime': assessment.timestamp.toIso8601String(),
      'extension': [
        {
          'url':
              'http://hl7.org/fhir/StructureDefinition/geolocation',
          'extension': [
            {
              'url': 'latitude',
              'valueDecimal': assessment.latitude,
            },
            {
              'url': 'longitude',
              'valueDecimal': assessment.longitude,
            },
          ],
        },
      ],
      'component': [
        {
          'code': {
            'coding': [
              {
                'system': 'http://loinc.org',
                'code': '84485-2',
                'display': 'Vector presence probability',
              },
            ],
            'text': 'Bioacoustic Mosquito Vector Probability',
          },
          'valueQuantity': {
            'value': (assessment.vectorOutbreakProbability * 100).round() / 100.0,
            'unit': 'probability',
            'system': 'http://unitsofmeasure.org',
            'code': '1',
          },
        },
        {
          'code': {
            'text': 'Citizen Validation Status',
          },
          'valueString': assessment.citizenConfirmedStandingWater
              ? 'Confirmed - Standing Water Observed'
              : 'Not Confirmed - Flowing Water',
        },
        {
          'code': {
            'coding': [
              {
                'system': 'http://loinc.org',
                'code': '80345-2',
                'display': 'Acoustic frequency measurement',
              },
            ],
            'text': 'Acoustic Fundamental Frequency Peak',
          },
          'valueQuantity': {
            'value': (assessment.peakFrequencyHz * 10).round() / 10.0,
            'unit': 'Hz',
            'system': 'http://unitsofmeasure.org',
            'code': 'Hz',
          },
        },
        {
          'code': {
            'text': 'Freshwater Ecosystem Quality Score',
          },
          'valueQuantity': {
            'value': assessment.ecosystemIntegrityScore,
            'unit': 'score (0-100)',
            'system': 'http://unitsofmeasure.org',
            'code': '1',
          },
        },
        {
          'code': {
            'text': 'One Health Risk Classification',
          },
          'valueCodeableConcept': {
            'coding': [
              {
                'system': 'http://snomed.info/sct',
                'code': assessment.vectorRisk == VectorRiskLevel.critical
                    ? '44558001'
                    : '10828004',
                'display': assessment.humanRiskLabel,
              },
            ],
            'text': assessment.humanRiskLabel,
          },
        },
        {
          'code': {
            'text': 'Stream Bank Morphology',
          },
          'valueString': assessment.bankCondition,
        },
        {
          'code': {
            'text': 'Municipal Vector Control Recommendation',
          },
          'valueString': assessment.municipalActionRecommendation,
        },
      ],
    };
  }

  /// Wraps the observation in a FHIR Bundle ready for municipal transmission.
  static Map<String, dynamic> buildBundle(OneHealthAssessment assessment) {
    final obs = buildObservation(assessment);
    return {
      'resourceType': 'Bundle',
      'id': 'bundle-${assessment.id}',
      'type': 'transaction',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'entry': [
        {
          'fullUrl': 'urn:uuid:${assessment.id}',
          'resource': obs,
          'request': {
            'method': 'POST',
            'url': 'Observation',
          },
        },
      ],
    };
  }

  /// Returns pretty-printed JSON string.
  static String formatJson(Map<String, dynamic> jsonMap) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }
}
