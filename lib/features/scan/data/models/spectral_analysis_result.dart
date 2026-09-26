/// Results of the Digital Signal Processing (DSP) and Radix-2 FFT evaluation.
class SpectralAnalysisResult {
  final double peakFrequencyHz;
  final double peakMagnitude;
  final double peakProminence;
  final bool isVectorBandPeak; // 450 - 650 Hz
  final double vectorBandEnergyRatio;
  final double bioacousticIndex;
  final double anthropophonyEnergy;
  final double biophonyEnergy;
  final int totalSamplesProcessed;
  final double sampleRate;
  final List<double> powerSpectrumSummary;

  const SpectralAnalysisResult({
    required this.peakFrequencyHz,
    required this.peakMagnitude,
    required this.peakProminence,
    required this.isVectorBandPeak,
    required this.vectorBandEnergyRatio,
    required this.bioacousticIndex,
    required this.anthropophonyEnergy,
    required this.biophonyEnergy,
    required this.totalSamplesProcessed,
    required this.sampleRate,
    required this.powerSpectrumSummary,
  });

  factory SpectralAnalysisResult.empty() {
    return const SpectralAnalysisResult(
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
    );
  }
}
