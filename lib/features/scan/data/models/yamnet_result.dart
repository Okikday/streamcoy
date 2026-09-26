/// Results from the YAMNet Deep Learning inference engine.
class YamnetResult {
  final double insectProbability;
  final double mosquitoProbability;
  final double amphibianFrogProbability;
  final double flowingWaterProbability;
  final double anthropicVehicleProbability;
  final String topClassLabel;
  final double topConfidence;

  const YamnetResult({
    required this.insectProbability,
    required this.mosquitoProbability,
    required this.amphibianFrogProbability,
    required this.flowingWaterProbability,
    required this.anthropicVehicleProbability,
    required this.topClassLabel,
    required this.topConfidence,
  });

  factory YamnetResult.empty() {
    return const YamnetResult(
      insectProbability: 0.0,
      mosquitoProbability: 0.0,
      amphibianFrogProbability: 0.0,
      flowingWaterProbability: 0.0,
      anthropicVehicleProbability: 0.0,
      topClassLabel: 'None',
      topConfidence: 0.0,
    );
  }
}
