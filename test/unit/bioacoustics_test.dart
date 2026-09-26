import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamcoy/features/scan/data/models/audio_scan_scenario.dart';
import 'package:streamcoy/features/scan/data/models/hitl_validation_data.dart';
import 'package:streamcoy/features/scan/data/models/one_health_assessment.dart';
import 'package:streamcoy/features/scan/logic/fft.dart';
import 'package:streamcoy/features/scan/logic/spectral_engine.dart';
import 'package:streamcoy/features/scan/logic/yamnet_engine.dart';
import 'package:streamcoy/features/scan/logic/one_health_engine.dart';
import 'package:streamcoy/features/export/fhir_bundle_builder.dart';

void main() {
  group('FFT & Digital Signal Processing Tests', () {
    test('FftEngine produces valid magnitude spectrum for sine input', () {
      const n = 1024;
      const sampleRate = 16000.0;
      const targetFreq = 542.0;

      // Generate pure sine wave at 542 Hz
      final signal = List<double>.generate(n, (i) {
        final t = i / sampleRate;
        return sin(2 * pi * targetFreq * t);
      });

      final windowed = FftEngine.applyHanningWindow(signal);
      final mags = FftEngine.computeMagnitudes(windowed);

      expect(mags.length, equals(n ~/ 2));

      // Find peak bin
      var maxMag = 0.0;
      var peakBin = 0;
      for (var i = 0; i < mags.length; i++) {
        if (mags[i] > maxMag) {
          maxMag = mags[i];
          peakBin = i;
        }
      }

      final detectedFreq = peakBin * (sampleRate / n);
      expect((detectedFreq - targetFreq).abs(), lessThan(20.0));
    });

    test('High-pass filter attenuates low frequency vehicle rumble', () {
      const n = 1000;
      const sampleRate = 16000.0;
      const lowFreq = 60.0;

      final lowFreqSignal = List<double>.generate(n, (i) {
        final t = i / sampleRate;
        return sin(2 * pi * lowFreq * t);
      });

      final filtered = FftEngine.applyHighPassFilter(
        lowFreqSignal,
        sampleRate: sampleRate,
        cutoffHz: 150.0,
      );

      expect(filtered.length, equals(n));
      // End of filtered signal should be substantially attenuated
      final endAmp = filtered.sublist(800).map((s) => s.abs()).reduce(max);
      expect(endAmp, lessThan(0.5));
    });
  });

  group('SpectralEngine & Dual-Engine Classifier Tests', () {
    test('Detects mosquito wingbeat peak within 450 - 650 Hz band', () {
      const sampleRate = 16000.0;
      const targetFreq = 542.0;

      // Synthesize 1 second with 542 Hz tone
      final buffer = List<double>.generate(16000, (i) {
        final t = i / sampleRate;
        return 0.1 * (sin(i) * 0.5) + 0.3 * sin(2 * pi * targetFreq * t);
      });

      final result = SpectralEngine.analyzeBuffer(buffer, sampleRate: sampleRate);

      expect(result.isVectorBandPeak, isTrue);
      expect((result.peakFrequencyHz - targetFreq).abs(), lessThan(25.0));
      expect(result.bioacousticIndex, greaterThan(0.0));
    });

    test('YamnetEngine flags mosquito probability high when vector peak exists', () {
      final spectral = SpectralEngine.analyzeBuffer(
        List<double>.generate(16000, (i) => sin(2 * pi * 542.0 * i / 16000.0)),
      );

      final result = YamnetEngine.classifyAudio(
        samples: List.filled(16000, 0.1),
        spectral: spectral,
        scenario: AudioScanScenario.stagnantCorridor,
      );

      expect(result.mosquitoProbability, greaterThan(0.6));
      expect(result.insectProbability, greaterThan(0.7));
    });
  });

  group('OneHealthEngine & FHIR Export Tests', () {
    test('Synthesizes critical vector risk and actionable municipal recommendations', () {
      final spectral = SpectralEngine.analyzeBuffer(
        List<double>.generate(16000, (i) => sin(2 * pi * 542.0 * i / 16000.0)),
      );
      final yamnet = YamnetEngine.classifyAudio(
        samples: List.filled(16000, 0.1),
        spectral: spectral,
        scenario: AudioScanScenario.stagnantCorridor,
      );
      final hitl = const HitlValidationData(
        visualSighting: VisualSightingStatus.yesStandingWater,
        bankMorphology: BankMorphology.moderateSlope,
        isFalsePositiveOverride: false,
      );

      final assessment = OneHealthEngine.synthesizeAssessment(
        spectral: spectral,
        yamnet: yamnet,
        hitl: hitl,
        scenario: AudioScanScenario.stagnantCorridor,
        tiltDegrees: 28.0,
      );

      expect(assessment.vectorRisk, equals(VectorRiskLevel.critical));
      expect(assessment.humanWellbeingRisk, equals(HumanWellbeingRiskLevel.severe));
      expect(assessment.municipalActionRecommendation, contains('Bti'));

      // Test HL7 FHIR Generation
      final fhirJson = FhirBundleBuilder.buildObservation(assessment);
      expect(fhirJson['resourceType'], equals('Observation'));
      expect(fhirJson['code']['coding'][0]['code'], equals('96608-5'));
      expect(fhirJson['component'], isNotEmpty);

      final bundleJson = FhirBundleBuilder.buildBundle(assessment);
      expect(bundleJson['resourceType'], equals('Bundle'));
      expect(bundleJson['entry'], isNotEmpty);
    });

    test('Citizen false positive override suppresses vector outbreak classification', () {
      final spectral = SpectralEngine.analyzeBuffer(
        List<double>.generate(16000, (i) => sin(2 * pi * 542.0 * i / 16000.0)),
      );
      final yamnet = YamnetEngine.classifyAudio(
        samples: List.filled(16000, 0.1),
        spectral: spectral,
        scenario: AudioScanScenario.stagnantCorridor,
      );
      final hitl = const HitlValidationData(
        visualSighting: VisualSightingStatus.yesStandingWater,
        bankMorphology: BankMorphology.naturalVegetated,
        isFalsePositiveOverride: true, // Citizen override
      );

      final assessment = OneHealthEngine.synthesizeAssessment(
        spectral: spectral,
        yamnet: yamnet,
        hitl: hitl,
        scenario: AudioScanScenario.stagnantCorridor,
        tiltDegrees: 28.0,
      );

      expect(assessment.vectorRisk, equals(VectorRiskLevel.low));
      expect(assessment.humanWellbeingRisk, equals(HumanWellbeingRiskLevel.minimal));
    });
  });
}
