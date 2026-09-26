import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../widgets/spectrogram_widget.dart';
import '../widgets/hitl_triage_widget.dart';

class HitlScreen extends ConsumerWidget {
  final VoidCallback onProceedToOneHealth;

  const HitlScreen({
    super.key,
    required this.onProceedToOneHealth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanPodProvider);
    final pod = ref.read(scanPodProvider.notifier);

    final spectral = state.spectralResult;
    final yamnet = state.yamnetResult;
    final isDetected = spectral.isVectorBandPeak &&
        !state.hitlData.isFalsePositiveOverride;

    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1526),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explainable AI & HITL Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Track 3: Explainable Bioacoustics Sentinel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Spectrogram Heatmap Card with Bounding Box
              SpectrogramWidget(
                frames: state.spectrogramFrames,
                isVectorDetected: isDetected,
                peakFrequencyHz: spectral.peakFrequencyHz > 0
                    ? spectral.peakFrequencyHz
                    : 542.0,
                height: 200,
              ),
              const SizedBox(height: 14),

              // 2. AI Diagnostic Note (Plain-Language Evidence Rationale)
              _buildAiDiagnosticRationaleCard(
                isDetected: isDetected,
                peakHz: spectral.peakFrequencyHz,
                prominence: spectral.peakProminence,
                yamnetInsectProb: yamnet.insectProbability,
                yamnetMosquitoProb: yamnet.mosquitoProbability,
                bi: spectral.bioacousticIndex,
                isOverride: state.hitlData.isFalsePositiveOverride,
              ),
              const SizedBox(height: 14),

              // 3. Dual-Engine Diagnostic Breakdown (YAMNet + Pure Dart FFT)
              _buildDualEngineBreakdown(spectral, yamnet),
              const SizedBox(height: 14),

              // 4. Citizen Verification Card (HITL Form)
              HitlTriageWidget(
                hitlData: state.hitlData,
                onChanged: (updated) => pod.updateHitlValidation(updated),
              ),
              const SizedBox(height: 18),

              // 5. Action Button to proceed to One Health Card
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF050B14),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  // Ensure assessment is computed
                  pod.updateHitlValidation(state.hitlData);
                  onProceedToOneHealth();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Validate & Generate One Health Card'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiDiagnosticRationaleCard({
    required bool isDetected,
    required double peakHz,
    required double prominence,
    required double yamnetInsectProb,
    required double yamnetMosquitoProb,
    required double bi,
    required bool isOverride,
  }) {
    Color cardColor;
    Color borderColor;
    IconData icon;
    String title;
    String message;

    if (isOverride) {
      cardColor = const Color(0xFFFFB300).withValues(alpha: 0.12);
      borderColor = const Color(0xFFFFB300);
      icon = Icons.cancel_outlined;
      title = 'Citizen Override Applied';
      message =
          'Acoustic resonance at ${peakHz.toStringAsFixed(1)} Hz flagged by citizen scientist as ambient mechanical equipment. Vector classification suppressed.';
    } else if (isDetected) {
      cardColor = const Color(0xFFFF5252).withValues(alpha: 0.12);
      borderColor = const Color(0xFFFF5252);
      icon = Icons.warning_amber_rounded;
      title = 'Culicidae Wingbeat Spike Identified';
      message =
          'Persistent narrow-band energy spike detected at ${peakHz.toStringAsFixed(1)} Hz (${prominence.toStringAsFixed(1)}x above noise floor). Matches Culex / Aedes flight harmonics. YAMNet insect confidence: ${(yamnetInsectProb * 100).toInt()}%.';
    } else {
      cardColor = const Color(0xFF00E676).withValues(alpha: 0.12);
      borderColor = const Color(0xFF00E676);
      icon = Icons.verified_rounded;
      title = 'Healthy Riparian Biophony Detected';
      message =
          'No vector harmonic wingbeat spikes detected in the 450 - 650 Hz band. Stream exhibits positive Bioacoustic Index (BI = ${bi.toStringAsFixed(2)}) with active biophonic aeration.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: borderColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualEngineBreakdown(
    dynamic spectral,
    dynamic yamnet,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Dual-Engine Bioacoustic Inference',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Offline MobileNet + FFT',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // YAMNet Sound Classes
          _buildProbBar(
            'Insect Biophony (ID: 125)',
            yamnet.insectProbability,
            const Color(0xFF00E5FF),
          ),
          const SizedBox(height: 8),
          _buildProbBar(
            'Culicidae / Mosquito (ID: 130)',
            yamnet.mosquitoProbability,
            const Color(0xFFFF5252),
          ),
          const SizedBox(height: 8),
          _buildProbBar(
            'Amphibian / Frog Chorus (ID: 136)',
            yamnet.amphibianFrogProbability,
            const Color(0xFF00E676),
          ),
          const SizedBox(height: 8),
          _buildProbBar(
            'Running Water Aeration (ID: 290)',
            yamnet.flowingWaterProbability,
            const Color(0xFF00B0FF),
          ),
          const SizedBox(height: 8),
          _buildProbBar(
            'Anthropic Rumble (ID: 300)',
            yamnet.anthropicVehicleProbability,
            const Color(0xFFFF9100),
          ),
          const Divider(color: Colors.white10, height: 20),

          // Deterministic FFT metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatPill(
                'Peak Frequency',
                '${spectral.peakFrequencyHz.toStringAsFixed(1)} Hz',
                spectral.isVectorBandPeak
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF00E5FF),
              ),
              _buildStatPill(
                'Prominence Q',
                '${spectral.peakProminence.toStringAsFixed(1)}x',
                const Color(0xFFFFD54F),
              ),
              _buildStatPill(
                'Bioacoustic Index',
                spectral.bioacousticIndex.toStringAsFixed(2),
                const Color(0xFF00E676),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbBar(String label, double prob, Color color) {
    final percent = (prob * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: prob.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}
