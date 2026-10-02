import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../../data/models/one_health_assessment.dart';
import '../widgets/triad_card.dart';
import '../widgets/fhir_json_viewer.dart';
import '../../../../core/ui/spacing.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/responsive_body.dart';

class OneHealthScreen extends ConsumerWidget {
  final VoidCallback onStartNewScan;

  const OneHealthScreen({
    super.key,
    required this.onStartNewScan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanPodProvider);
    final pod = ref.read(scanPodProvider.notifier);
    final assessment = state.currentAssessment;

    if (assessment == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF070E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A1526),
          title: const Text(
            'One Health Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: ResponsiveBody(
          child: Center(
            child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 56, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text(
                  'No Active Assessment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete a field scan to generate your\nOne Health Triad report.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Step flow guide
                _buildStepFlow(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF050B14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                  onPressed: onStartNewScan,
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text('Start a Scan'),
                ),
              ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1526),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'One Health Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'IEEE OneAquaHealth • Track 3 & 7',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View HL7 FHIR JSON',
            icon: const Icon(Icons.data_object_rounded,
                color: Color(0xFF00E5FF)),
            onPressed: () => FhirJsonViewer.show(context, assessment),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenInsets,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Environmental Context
              _buildEnvironmentalContextBar(assessment),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── TRIAD SYNTHESIS ──
              const SectionHeader(
                title: 'TRIAD SYNTHESIS',
                subtitle: 'Ecosystem × Vector × Human',
                icon: Icons.hub_rounded,
              ),
              TriadCard(assessment: assessment),
              const SizedBox(height: AppSpacing.cardGap),

              // Municipal Action Card
              _buildMunicipalBiocontrolCard(context, assessment),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── ACTIONS ──
              const SectionHeader(
                title: 'ACTIONS',
                icon: Icons.send_rounded,
              ),

              // Primary CTA: Submit to Hub
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isSubmittedToHub
                        ? const Color(0xFF00E676)
                        : const Color(0xFF00E5FF),
                    foregroundColor: const Color(0xFF050B14),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: state.isSubmittedToHub
                      ? null
                      : () async {
                          final success =
                              await pod.submitAssessmentToHub();
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF00E676),
                                content: Text(
                                  'FHIR Observation synced with Municipal Hub',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    state.isSubmittedToHub
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_rounded,
                    size: 18,
                  ),
                  label: Text(
                    state.isSubmittedToHub
                        ? 'Synced to Hub'
                        : 'Submit to Municipal Hub',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.tightGap),

              // Secondary actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        FhirJsonViewer.show(context, assessment),
                    icon: const Icon(Icons.code_rounded,
                        size: 16, color: Color(0xFF00E5FF)),
                    label: const Text(
                      'View FHIR JSON',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onStartNewScan,
                    icon: const Icon(Icons.add_location_alt_rounded,
                        size: 16, color: Colors.white70),
                    label: const Text(
                      'New Scan',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.cardGap),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Step flow for the empty state onboarding.
  Widget _buildStepFlow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot('1', 'Scan', Icons.mic_rounded),
        _buildStepArrow(),
        _buildStepDot('2', 'Review', Icons.auto_graph_rounded),
        _buildStepArrow(),
        _buildStepDot('3', 'Report', Icons.hub_rounded),
      ],
    );
  }

  Widget _buildStepDot(String number, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            ),
          ),
          child: Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white.withValues(alpha: 0.2),
        size: 16,
      ),
    );
  }

  Widget _buildEnvironmentalContextBar(OneHealthAssessment assessment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location row
          Row(
            children: [
              const Icon(Icons.fmd_good_rounded,
                  color: Color(0xFF00E5FF), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.locationSector,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${assessment.latitude.toStringAsFixed(4)}°N, ${assessment.longitude.toStringAsFixed(4)}°W',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Environment tags row — wraps on narrow screens
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildEnvTag(
                Icons.thermostat_rounded,
                '${assessment.temperatureCelsius.toStringAsFixed(1)}°C',
                const Color(0xFFFF9100),
              ),
              _buildEnvTag(
                Icons.water_drop_rounded,
                '${assessment.relativeHumidityPercent.toStringAsFixed(0)}% RH',
                const Color(0xFF00E5FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalBiocontrolCard(
      BuildContext context, OneHealthAssessment assessment) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.innerCardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF14243D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined,
                  color: Color(0xFFFFD54F), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Municipal Action Protocol',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            assessment.municipalActionRecommendation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: Culex pipiens, Aedes albopictus. Verified via FFT & citizen sighting.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
