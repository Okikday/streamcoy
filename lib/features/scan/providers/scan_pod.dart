import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/audio_scan_scenario.dart';
import '../data/models/hitl_validation_data.dart';
import '../data/models/one_health_assessment.dart';
import '../logic/audio_synthesizer.dart';
import '../logic/spectral_engine.dart';
import '../logic/spectrogram_service.dart';
import '../logic/yamnet_engine.dart';
import '../logic/one_health_engine.dart';
import 'scan_state.dart';

final scanPodProvider = NotifierProvider<ScanPod, ScanState>(
  ScanPod.new,
  name: 'ScanPod',
);

class ScanPod extends Notifier<ScanState> {
  Timer? _timer;
  final AudioSynthesizer _synthesizer = AudioSynthesizer();

  @override
  ScanState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Provide pre-seeded initial history for demo presentation
    final initialHistory = _createInitialHistoricalAssessments();
    return ScanState(
      history: initialHistory,
    );
  }

  /// Change active scenario preset (e.g. Stagnant Corridor, Pristine Brook, etc.)
  void setScenario(AudioScanScenario scenario) {
    if (state.isRecording) return;
    state = state.copyWith(
      selectedScenario: scenario,
      tiltDegrees: scenario.simulatedTiltDegrees,
      customToneFrequency: scenario.dominantFrequency > 0
          ? scenario.dominantFrequency
          : 542.0,
      hitlData: HitlValidationData(
        visualSighting: scenario.hasMosquitoHarmonic
            ? VisualSightingStatus.yesStandingWater
            : VisualSightingStatus.noStandingWater,
        bankMorphology: scenario.type == ScenarioType.urbanCulvert
            ? BankMorphology.steepArtificial
            : BankMorphology.naturalVegetated,
        isFalsePositiveOverride: false,
      ),
    );
  }

  /// Adjust simulated device tilt angle (degrees downwards)
  void setTiltDegrees(double degrees) {
    state = state.copyWith(tiltDegrees: degrees.clamp(0.0, 90.0));
  }

  /// Adjust synthetic tone frequency for live testing
  void setCustomToneFrequency(double freq) {
    state = state.copyWith(customToneFrequency: freq.clamp(300.0, 800.0));
  }

  /// Start the 30-second standardized field audio capture
  void startScan({int durationSeconds = 30}) {
    _timer?.cancel();
    final newSamples = <double>[];
    state = state.copyWith(
      isRecording: true,
      isAnalyzing: false,
      currentSeconds: 0,
      totalScanDurationSeconds: durationSeconds,
      audioSamples: newSamples,
      recentWaveform: const [],
      spectrogramFrames: const [],
      isSubmittedToHub: false,
      statusMessage: 'Recording raw 16 kHz stream acoustics...',
    );

    const sampleRate = 16000;
    var accumulatedSeconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (accumulatedSeconds >= durationSeconds) {
        stopScan();
        return;
      }

      // Generate 1 second of 16 kHz audio samples
      final chunk = _synthesizer.generateSecondBlock(
        scenario: state.selectedScenario,
        currentSecond: accumulatedSeconds,
        sampleRate: sampleRate,
        customToneFreq: state.selectedScenario.type == ScenarioType.customTone
            ? state.customToneFrequency
            : null,
      );

      newSamples.addAll(chunk);
      accumulatedSeconds += 1;

      // Extract downsampled waveform window for visualizer (e.g., 64 bars)
      final waveform = _extractWaveformSlice(chunk, 64);

      // Compute live spectrogram frames for recent audio (last 3-4 seconds)
      final specSliceStart = max(0, newSamples.length - (sampleRate * 4));
      final specSlice = newSamples.sublist(specSliceStart);
      final frames = SpectrogramService.computeSpectrogram(
        specSlice,
        frameSize: 1024,
        hopSize: 512,
        sampleRate: sampleRate.toDouble(),
        targetMaxHz: 4000.0,
      );

      state = state.copyWith(
        currentSeconds: accumulatedSeconds,
        audioSamples: List<double>.from(newSamples),
        recentWaveform: waveform,
        spectrogramFrames: frames,
      );

      if (accumulatedSeconds >= durationSeconds) {
        stopScan();
      }
    });
  }

  /// Manually or automatically finish capture and execute dual-engine analysis
  void stopScan() {
    _timer?.cancel();
    if (!state.isRecording && state.audioSamples.isNotEmpty) {
      _executeAnalysis();
      return;
    }

    state = state.copyWith(
      isRecording: false,
      isAnalyzing: true,
      statusMessage: 'Synthesizing FFT & YAMNet inferences...',
    );

    _executeAnalysis();
  }

  /// Reset the scan state to start over
  void resetScan() {
    _timer?.cancel();
    state = state.copyWith(
      isRecording: false,
      isAnalyzing: false,
      currentSeconds: 0,
      audioSamples: const [],
      recentWaveform: const [],
      spectrogramFrames: const [],
      currentAssessment: null,
      isSubmittedToHub: false,
      statusMessage: 'Ready for acoustic scan',
    );
  }

  /// Instant full 30-second scan simulation for rapid hackathon testing & demo
  void quickSimulateFullScan() {
    _timer?.cancel();
    state = state.copyWith(
      isRecording: false,
      isAnalyzing: true,
      currentSeconds: 30,
      totalScanDurationSeconds: 30,
      statusMessage: 'Generating 480,000 sample 30s acoustic buffer...',
    );

    const sampleRate = 16000;
    const duration = 30;
    final allSamples = <double>[];

    for (var s = 0; s < duration; s++) {
      final chunk = _synthesizer.generateSecondBlock(
        scenario: state.selectedScenario,
        currentSecond: s,
        sampleRate: sampleRate,
        customToneFreq: state.selectedScenario.type == ScenarioType.customTone
            ? state.customToneFrequency
            : null,
      );
      allSamples.addAll(chunk);
    }

    final waveform = _extractWaveformSlice(
      allSamples.sublist(allSamples.length - sampleRate),
      64,
    );

    // Compute comprehensive spectrogram
    final frames = SpectrogramService.computeSpectrogram(
      allSamples.sublist(max(0, allSamples.length - (sampleRate * 6))),
      frameSize: 1024,
      hopSize: 512,
      sampleRate: sampleRate.toDouble(),
      targetMaxHz: 4000.0,
    );

    state = state.copyWith(
      audioSamples: allSamples,
      recentWaveform: waveform,
      spectrogramFrames: frames,
    );

    _executeAnalysis();
  }

  /// Run dual-engine spectral analysis, YAMNet inference, and One Health synthesis
  void _executeAnalysis() {
    final samples = state.audioSamples;
    if (samples.isEmpty) {
      state = state.copyWith(isAnalyzing: false);
      return;
    }

    // 1. Digital Signal Processing (Radix-2 FFT & Peak Prominence)
    final spectral = SpectralEngine.analyzeBuffer(
      samples,
      sampleRate: 16000.0,
      fftSize: 1024,
    );

    // 2. YAMNet MobileNet-v1 Neural Inference
    final yamnet = YamnetEngine.classifyAudio(
      samples: samples,
      spectral: spectral,
      scenario: state.selectedScenario,
    );

    // 3. One Health Triad Diagnostic Synthesis
    final assessment = OneHealthEngine.synthesizeAssessment(
      spectral: spectral,
      yamnet: yamnet,
      hitl: state.hitlData,
      scenario: state.selectedScenario,
      tiltDegrees: state.tiltDegrees,
    );

    // Compute complete multi-frame spectrogram for HITL visualization screen
    final specFrames = SpectrogramService.computeSpectrogram(
      samples.sublist(max(0, samples.length - 16000 * 6)),
      frameSize: 1024,
      hopSize: 512,
      sampleRate: 16000.0,
      targetMaxHz: 4000.0,
    );

    state = state.copyWith(
      isAnalyzing: false,
      isRecording: false,
      spectralResult: spectral,
      yamnetResult: yamnet,
      currentAssessment: assessment,
      spectrogramFrames: specFrames,
      statusMessage: 'Analysis Complete: ${assessment.humanRiskLabel}',
    );
  }

  /// Update citizen validation input (Human-in-the-Loop)
  void updateHitlValidation(HitlValidationData updatedHitl) {
    state = state.copyWith(hitlData: updatedHitl);

    // Re-synthesize assessment with updated citizen input
    if (state.audioSamples.isNotEmpty) {
      final updatedAssessment = OneHealthEngine.synthesizeAssessment(
        spectral: state.spectralResult,
        yamnet: state.yamnetResult,
        hitl: updatedHitl,
        scenario: state.selectedScenario,
        tiltDegrees: state.tiltDegrees,
      );
      state = state.copyWith(currentAssessment: updatedAssessment);
    }
  }

  /// Submit Observation to Municipal OneHealth Hub (simulated HL7 FHIR upload)
  Future<bool> submitAssessmentToHub() async {
    final assessment = state.currentAssessment;
    if (assessment == null) return false;

    state = state.copyWith(
      statusMessage: 'Transmitting HL7 FHIR Observation to Hub...',
    );

    await Future.delayed(const Duration(milliseconds: 650));

    final updatedHistory = [assessment, ...state.history];
    state = state.copyWith(
      isSubmittedToHub: true,
      history: updatedHistory,
      statusMessage: 'Observation successfully ingested into Municipal Registry (LOINC 96608-5)',
    );

    return true;
  }

  /// Helper to extract normalized waveform bars
  List<double> _extractWaveformSlice(List<double> samples, int barCount) {
    if (samples.isEmpty) return List.filled(barCount, 0.05);
    final slice = <double>[];
    final step = max(1, samples.length ~/ barCount);

    for (var i = 0; i < barCount; i++) {
      final start = i * step;
      final end = min(samples.length, start + step);
      var maxVal = 0.0;
      for (var j = start; j < end; j++) {
        final abs = samples[j].abs();
        if (abs > maxVal) maxVal = abs;
      }
      slice.add(maxVal.clamp(0.04, 1.0));
    }
    return slice;
  }

  /// Pre-populated historical field observations for realistic demo experience
  List<OneHealthAssessment> _createInitialHistoricalAssessments() {
    return [
      OneHealthAssessment(
        id: 'echostream-obs-20260925-104921',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        locationSector: 'Sector Charlie - Lower Mondego Retention Pond',
        latitude: 40.2112,
        longitude: -8.4289,
        temperatureCelsius: 26.2,
        relativeHumidityPercent: 82.0,
        ecosystemIntegrityScore: 36.5,
        ecosystemSummary:
            'Severe Eutrophication: Dense algal bloom, standing water, and suppressed flow aeration.',
        vectorRisk: VectorRiskLevel.critical,
        vectorOutbreakProbability: 0.89,
        vectorSummary:
            'Critical Vector Breeding: Strong 546 Hz resonance detected with extensive larval swarms.',
        humanWellbeingRisk: HumanWellbeingRiskLevel.severe,
        municipalActionRecommendation:
            'Immediate Bti biological larvicide dispersion authorized by municipal health department.',
        plainLanguageExplanation:
            'Persistent Culicidae wingbeat detected at 546 Hz in stagnant retention pond.',
        peakFrequencyHz: 546.0,
        mosquitoHarmonicDetected: true,
        yamnetInsectConfidence: 0.91,
        citizenConfirmedStandingWater: true,
        bankCondition: 'Moderate Slope (25-50°)',
        isMarkedFalsePositive: false,
      ),
      OneHealthAssessment(
        id: 'echostream-obs-20260924-142210',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        locationSector: 'Sector Bravo - Botanical Garden Creek',
        latitude: 40.2078,
        longitude: -8.4234,
        temperatureCelsius: 22.0,
        relativeHumidityPercent: 62.0,
        ecosystemIntegrityScore: 88.0,
        ecosystemSummary:
            'High Riparian Health: Continuous bubbling cascade, dense native fern bank, active frog chorus.',
        vectorRisk: VectorRiskLevel.low,
        vectorOutbreakProbability: 0.08,
        vectorSummary:
            'Low Vector Presence: Aerated rapid flow prevents mosquito oviposition.',
        humanWellbeingRisk: HumanWellbeingRiskLevel.minimal,
        municipalActionRecommendation:
            'Routine bi-weekly monitoring. Maintain existing riparian buffer vegetation.',
        plainLanguageExplanation:
            'High Bioacoustic Index (BI = 2.4) with dominant amphibian and water biophony.',
        peakFrequencyHz: 1850.0,
        mosquitoHarmonicDetected: false,
        yamnetInsectConfidence: 0.44,
        citizenConfirmedStandingWater: false,
        bankCondition: 'Natural Vegetated (<25°)',
        isMarkedFalsePositive: false,
      ),
    ];
  }
}
