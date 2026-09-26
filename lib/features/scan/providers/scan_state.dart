import '../data/models/audio_scan_scenario.dart';
import '../data/models/spectral_analysis_result.dart';
import '../data/models/yamnet_result.dart';
import '../data/models/hitl_validation_data.dart';
import '../data/models/one_health_assessment.dart';

class ScanState {
  final bool isRecording;
  final bool isAnalyzing;
  final int currentSeconds;
  final int totalScanDurationSeconds;
  final List<double> audioSamples;
  final List<double> recentWaveform;
  final List<List<double>> spectrogramFrames;
  final double tiltDegrees;
  final AudioScanScenario selectedScenario;
  final double customToneFrequency;
  final SpectralAnalysisResult spectralResult;
  final YamnetResult yamnetResult;
  final HitlValidationData hitlData;
  final OneHealthAssessment? currentAssessment;
  final List<OneHealthAssessment> history;
  final bool isSubmittedToHub;
  final String? statusMessage;

  const ScanState({
    this.isRecording = false,
    this.isAnalyzing = false,
    this.currentSeconds = 0,
    this.totalScanDurationSeconds = 30,
    this.audioSamples = const [],
    this.recentWaveform = const [],
    this.spectrogramFrames = const [],
    this.tiltDegrees = 28.0,
    this.selectedScenario = AudioScanScenario.stagnantCorridor,
    this.customToneFrequency = 542.0,
    this.spectralResult = const SpectralAnalysisResult(
      peakFrequencyHz: 0.0,
      peakMagnitude: 0.0,
      peakProminence: 0.0,
      isVectorBandPeak: false,
      vectorBandEnergyRatio: 0.0,
      bioacousticIndex: 0.0,
      anthropophonyEnergy: 0.0,
      biophonyEnergy: 0.0,
      totalSamplesProcessed: 0,
      sampleRate: 16000.0,
      powerSpectrumSummary: [],
    ),
    this.yamnetResult = const YamnetResult(
      insectProbability: 0.0,
      mosquitoProbability: 0.0,
      amphibianFrogProbability: 0.0,
      flowingWaterProbability: 0.0,
      anthropicVehicleProbability: 0.0,
      topClassLabel: 'None',
      topConfidence: 0.0,
    ),
    this.hitlData = const HitlValidationData(),
    this.currentAssessment,
    this.history = const [],
    this.isSubmittedToHub = false,
    this.statusMessage,
  });

  bool get isOptimalTilt => tiltDegrees >= 15.0 && tiltDegrees <= 45.0;

  double get scanProgress => totalScanDurationSeconds > 0
      ? (currentSeconds / totalScanDurationSeconds).clamp(0.0, 1.0)
      : 0.0;

  int get totalSampleCount => audioSamples.length;

  ScanState copyWith({
    bool? isRecording,
    bool? isAnalyzing,
    int? currentSeconds,
    int? totalScanDurationSeconds,
    List<double>? audioSamples,
    List<double>? recentWaveform,
    List<List<double>>? spectrogramFrames,
    double? tiltDegrees,
    AudioScanScenario? selectedScenario,
    double? customToneFrequency,
    SpectralAnalysisResult? spectralResult,
    YamnetResult? yamnetResult,
    HitlValidationData? hitlData,
    OneHealthAssessment? currentAssessment,
    List<OneHealthAssessment>? history,
    bool? isSubmittedToHub,
    String? statusMessage,
  }) {
    return ScanState(
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalScanDurationSeconds:
          totalScanDurationSeconds ?? this.totalScanDurationSeconds,
      audioSamples: audioSamples ?? this.audioSamples,
      recentWaveform: recentWaveform ?? this.recentWaveform,
      spectrogramFrames: spectrogramFrames ?? this.spectrogramFrames,
      tiltDegrees: tiltDegrees ?? this.tiltDegrees,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      customToneFrequency: customToneFrequency ?? this.customToneFrequency,
      spectralResult: spectralResult ?? this.spectralResult,
      yamnetResult: yamnetResult ?? this.yamnetResult,
      hitlData: hitlData ?? this.hitlData,
      currentAssessment: currentAssessment ?? this.currentAssessment,
      history: history ?? this.history,
      isSubmittedToHub: isSubmittedToHub ?? this.isSubmittedToHub,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
