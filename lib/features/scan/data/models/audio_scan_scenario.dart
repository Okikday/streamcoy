/// Predefined scenarios for demonstration and testing of EchoStream.
enum ScenarioType {
  stagnantCorridor,
  pristineBrook,
  urbanCulvert,
  customTone,
}

class AudioScanScenario {
  final ScenarioType type;
  final String title;
  final String description;
  final double dominantFrequency;
  final bool hasMosquitoHarmonic;
  final double waterFlowEnergy;
  final double frogCallEnergy;
  final double urbanNoiseEnergy;
  final double simulatedTiltDegrees;
  final String locationSector;

  const AudioScanScenario({
    required this.type,
    required this.title,
    required this.description,
    required this.dominantFrequency,
    required this.hasMosquitoHarmonic,
    required this.waterFlowEnergy,
    required this.frogCallEnergy,
    required this.urbanNoiseEnergy,
    required this.simulatedTiltDegrees,
    required this.locationSector,
  });

  static const stagnantCorridor = AudioScanScenario(
    type: ScenarioType.stagnantCorridor,
    title: 'Stagnant Stream Sector (Outbreak Risk)',
    description:
        'Coimbra Urban Corridor Sector Alpha: low flow velocity, standing pools, 542 Hz Culicidae wingbeat harmonic.',
    dominantFrequency: 542.0,
    hasMosquitoHarmonic: true,
    waterFlowEnergy: 0.2,
    frogCallEnergy: 0.05,
    urbanNoiseEnergy: 0.15,
    simulatedTiltDegrees: 28.0,
    locationSector: 'Sector Alpha - Coimbra Riparian Corridor',
  );

  static const pristineBrook = AudioScanScenario(
    type: ScenarioType.pristineBrook,
    title: 'Pristine Riparian Brook (Healthy)',
    description:
        'Mondego Natural Tributary: active water aeration, high amphibian biophony, no mosquito flight tones.',
    dominantFrequency: 0.0,
    hasMosquitoHarmonic: false,
    waterFlowEnergy: 0.85,
    frogCallEnergy: 0.65,
    urbanNoiseEnergy: 0.05,
    simulatedTiltDegrees: 32.0,
    locationSector: 'Mondego Headwaters - Bio Reserve Sector B',
  );

  static const urbanCulvert = AudioScanScenario(
    type: ScenarioType.urbanCulvert,
    title: 'Urban Concrete Culvert (Anthropic Noise)',
    description:
        'Highway Underpass Drainage: heavy vehicle low-frequency rumble, minimal biophony, steep artificial bank.',
    dominantFrequency: 120.0,
    hasMosquitoHarmonic: false,
    waterFlowEnergy: 0.35,
    frogCallEnergy: 0.0,
    urbanNoiseEnergy: 0.80,
    simulatedTiltDegrees: 58.0,
    locationSector: 'Expressway Culvert 04 - Industrial Zone',
  );

  static const customTone = AudioScanScenario(
    type: ScenarioType.customTone,
    title: 'Interactive Synthetic Tone Simulator',
    description:
        'Custom adjustable frequency generator (400 - 700 Hz) to verify narrow-band FFT peak detection in real time.',
    dominantFrequency: 542.0,
    hasMosquitoHarmonic: true,
    waterFlowEnergy: 0.25,
    frogCallEnergy: 0.1,
    urbanNoiseEnergy: 0.1,
    simulatedTiltDegrees: 30.0,
    locationSector: 'Field Validation Laboratory Bench',
  );

  static const List<AudioScanScenario> presets = [
    stagnantCorridor,
    pristineBrook,
    urbanCulvert,
    customTone,
  ];
}
