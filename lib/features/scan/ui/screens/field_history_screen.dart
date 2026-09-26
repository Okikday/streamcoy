import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../../data/models/one_health_assessment.dart';
import '../widgets/fhir_json_viewer.dart';

class FieldHistoryScreen extends ConsumerWidget {
  const FieldHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanPodProvider);
    final history = state.history;

    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1526),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riparian Audit Log',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Synchronized Municipal Sentinel Stream Records',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const Text(
                    'No Stored Observations',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItemCard(context, item);
              },
            ),
    );
  }

  Widget _buildHistoryItemCard(BuildContext context, OneHealthAssessment item) {
    final isCritical = item.vectorRisk == VectorRiskLevel.critical;
    final riskColor = isCritical
        ? const Color(0xFFFF5252)
        : (item.vectorRisk == VectorRiskLevel.moderate
            ? const Color(0xFFFFB300)
            : const Color(0xFF00E676));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFFF5252).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.id,
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: riskColor, width: 0.8),
                ),
                child: Text(
                  item.vectorRiskLabel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.locationSector,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} • Peak: ${item.peakFrequencyHz.toStringAsFixed(1)} Hz • Eco Score: ${item.ecosystemIntegrityScore.toStringAsFixed(1)}/100',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.plainLanguageExplanation,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FHIR LOINC 96608-5',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: const Color(0xFF00E5FF),
                ),
                onPressed: () => FhirJsonViewer.show(context, item),
                icon: const Icon(Icons.code_rounded, size: 14),
                label: const Text('Inspect FHIR JSON',
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
