import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../widgets/triad_card.dart';
import '../widgets/fhir_json_viewer.dart';

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
          title: const Text('One Health Diagnostic Hub'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 48, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              const Text(
                'No Active Field Assessment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete a 30s stream scan to generate the One Health Triad report.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF050B14),
                ),
                onPressed: onStartNewScan,
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Initiate Sentinel Scan'),
              ),
            ],
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
              'One Health Sentinel Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'IEEE OneAquaHealth • Track 3 & 7 Compliance',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View HL7 FHIR JSON',
            icon: const Icon(Icons.data_object_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => FhirJsonViewer.show(context, assessment),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Environmental Context Bar (GPS + Weather)
              _buildEnvironmentalContextBar(assessment),
              const SizedBox(height: 14),

              // Triad Synthesis Card
              TriadCard(assessment: assessment),
              const SizedBox(height: 14),

              // Actionable Municipal Biocontrol Recommendation Card
              _buildMunicipalBiocontrolCard(context, assessment),
              const SizedBox(height: 16),

              // Submission & FHIR Interoperability Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00E5FF),
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => FhirJsonViewer.show(context, assessment),
                      icon: const Icon(Icons.code_rounded, size: 18),
                      label: const Text(
                        'View FHIR JSON',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isSubmittedToHub
                            ? const Color(0xFF00E676)
                            : const Color(0xFF00E5FF),
                        foregroundColor: const Color(0xFF050B14),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: state.isSubmittedToHub
                          ? null
                          : () async {
                              final success = await pod.submitAssessmentToHub();
                              if (context.mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF00E676),
                                    content: Text(
                                      'FHIR Observation synced with Municipal OneHealth Hub',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
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
                            : 'Submit to Hub',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton.icon(
                  onPressed: onStartNewScan,
                  icon: const Icon(Icons.add_location_alt_rounded,
                      size: 16, color: Colors.white70),
                  label: const Text(
                    'Initiate Scan on Next Stream Corridor',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalContextBar(dynamic assessment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.fmd_good_rounded,
                  color: Color(0xFF00E5FF), size: 16),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assessment.locationSector,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${assessment.latitude.toStringAsFixed(4)}°N, ${assessment.longitude.toStringAsFixed(4)}°W',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 9.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildEnvTag(
                Icons.thermostat_rounded,
                '${assessment.temperatureCelsius.toStringAsFixed(1)}°C',
                const Color(0xFFFF9100),
              ),
              const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalBiocontrolCard(
      BuildContext context, dynamic assessment) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(
                'Municipal Action Protocol (One Health)',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            assessment.municipalActionRecommendation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target Species: Culex pipiens (West Nile Vector), Aedes albopictus (Tiger Mosquito). Verified via rad-2 FFT & citizen sighting.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
