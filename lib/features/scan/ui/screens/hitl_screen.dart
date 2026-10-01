import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../../data/models/spectral_analysis_result.dart';
import '../../data/models/yamnet_result.dart';
import '../widgets/spectrogram_widget.dart';
import '../widgets/hitl_triage_widget.dart';
import '../../../../core/ui/spacing.dart';
import '../../../../core/ui/section_header.dart';

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
              'AI Review & Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Explainable Bioacoustics • Track 3',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AI ANALYSIS RESULTS ──
              const SectionHeader(
                title: 'AI ANALYSIS',
                subtitle: 'Dual-engine bioacoustic inference',
                icon: Icons.auto_graph_rounded,
              ),

              // 1. Spectrogram Heatmap Card
              SpectrogramWidget(
                frames: state.spectrogramFrames,
                isVectorDetected: isDetected,
                peakFrequencyHz: spectral.peakFrequencyHz > 0
                    ? spectral.peakFrequencyHz
                    : 542.0,
                height: 200,
              ),
              const SizedBox(height: AppSpacing.cardGap),

              // 2. AI Diagnostic Rationale (plain-language)
              _AiDiagnosticCard(
                isDetected: isDetected,
                peakHz: spectral.peakFrequencyHz,
                prominence: spectral.peakProminence,
                yamnetInsectProb: yamnet.insectProbability,
                bi: spectral.bioacousticIndex,
                isOverride: state.hitlData.isFalsePositiveOverride,
              ),
              const SizedBox(height: AppSpacing.cardGap),

              // 3. Key Metrics Summary (always visible) + Collapsible Detail
              _CollapsibleDualEngineBreakdown(
                spectral: spectral,
                yamnet: yamnet,
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── FIELD VERIFICATION ──
              const SectionHeader(
                title: 'YOUR VERIFICATION',
                subtitle: 'Citizen science confirmation (HITL)',
                icon: Icons.verified_user_rounded,
              ),

              // 4. HITL Triage Form
              HitlTriageWidget(
                hitlData: state.hitlData,
                onChanged: (updated) => pod.updateHitlValidation(updated),
              ),
              const SizedBox(height: AppSpacing.cardGap),

              // 5. Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF050B14),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    pod.updateHitlValidation(state.hitlData);
                    onProceedToOneHealth();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Generate One Health Report'),
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plain-language AI diagnostic explanation card.
class _AiDiagnosticCard extends StatelessWidget {
  final bool isDetected;
  final double peakHz;
  final double prominence;
  final double yamnetInsectProb;
  final double bi;
  final bool isOverride;

  const _AiDiagnosticCard({
    required this.isDetected,
    required this.peakHz,
    required this.prominence,
    required this.yamnetInsectProb,
    required this.bi,
    required this.isOverride,
  });

  @override
  Widget build(BuildContext context) {
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
          'Acoustic resonance at ${peakHz.toStringAsFixed(1)} Hz flagged as ambient mechanical equipment. Vector classification suppressed.';
    } else if (isDetected) {
      cardColor = const Color(0xFFFF5252).withValues(alpha: 0.12);
      borderColor = const Color(0xFFFF5252);
      icon = Icons.warning_amber_rounded;
      title = 'Culicidae Wingbeat Spike Identified';
      message =
          'Energy spike at ${peakHz.toStringAsFixed(1)} Hz (${prominence.toStringAsFixed(1)}x above noise floor). Matches Culex/Aedes flight harmonics. YAMNet insect confidence: ${(yamnetInsectProb * 100).toInt()}%.';
    } else {
      cardColor = const Color(0xFF00E676).withValues(alpha: 0.12);
      borderColor = const Color(0xFF00E676);
      icon = Icons.verified_rounded;
      title = 'Healthy Riparian Biophony';
      message =
          'No vector wingbeat spikes in the 450–650 Hz band. Bioacoustic Index: ${bi.toStringAsFixed(2)} — active biophonic aeration.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.innerCardPadding),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Key stat pills always visible, detailed probability bars collapsed by default.
class _CollapsibleDualEngineBreakdown extends StatelessWidget {
  final SpectralAnalysisResult spectral;
  final YamnetResult yamnet;

  const _CollapsibleDualEngineBreakdown({
    required this.spectral,
    required this.yamnet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Always-visible summary: key metrics
          Padding(
            padding: const EdgeInsets.all(AppSpacing.innerCardPadding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dual-Engine Inference',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'FFT + MobileNet',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Key stat pills — always visible
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill(
                      'Peak Freq',
                      '${spectral.peakFrequencyHz.toStringAsFixed(1)} Hz',
                      spectral.isVectorBandPeak
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF00E5FF),
                    ),
                    _buildStatPill(
                      'Prominence',
                      '${spectral.peakProminence.toStringAsFixed(1)}x',
                      const Color(0xFFFFD54F),
                    ),
                    _buildStatPill(
                      'BI Score',
                      spectral.bioacousticIndex.toStringAsFixed(2),
                      const Color(0xFF00E676),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable detail — probability bars
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.innerCardPadding),
              title: Text(
                'View Detailed Breakdown',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor: Colors.white38,
              collapsedIconColor: Colors.white38,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.innerCardPadding,
                      0,
                      AppSpacing.innerCardPadding,
                      AppSpacing.innerCardPadding),
                  child: Column(
                    children: [
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 14),
                      _buildProbBar(
                        'Insect Biophony (ID: 125)',
                        yamnet.insectProbability,
                        const Color(0xFF00E5FF),
                      ),
                      const SizedBox(height: 12),
                      _buildProbBar(
                        'Culicidae / Mosquito (ID: 130)',
                        yamnet.mosquitoProbability,
                        const Color(0xFFFF5252),
                      ),
                      const SizedBox(height: 12),
                      _buildProbBar(
                        'Amphibian / Frog (ID: 136)',
                        yamnet.amphibianFrogProbability,
                        const Color(0xFF00E676),
                      ),
                      const SizedBox(height: 12),
                      _buildProbBar(
                        'Running Water (ID: 290)',
                        yamnet.flowingWaterProbability,
                        const Color(0xFF00B0FF),
                      ),
                      const SizedBox(height: 12),
                      _buildProbBar(
                        'Anthropic Rumble (ID: 300)',
                        yamnet.anthropicVehicleProbability,
                        const Color(0xFFFF9100),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percent%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: prob.clamp(0.0, 1.0),
            minHeight: 5,
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
