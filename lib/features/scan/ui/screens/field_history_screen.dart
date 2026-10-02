import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../../data/models/one_health_assessment.dart';
import '../widgets/fhir_json_viewer.dart';
import '../../../../core/ui/spacing.dart';
import '../../../../core/ui/responsive_body.dart';

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
              'Scan History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${history.length} sentinel records',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: history.isEmpty
          ? ResponsiveBody(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded,
                        size: 56, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    const Text(
                      'No Stored Observations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed scans will appear here.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ResponsiveBody(
              child: ListView.builder(
                padding: AppSpacing.screenInsets,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _HistoryItemCard(item: item);
                },
              ),
            ),
    );
  }
}

/// Collapsible history card — shows key info at a glance, detail on tap.
class _HistoryItemCard extends StatelessWidget {
  final OneHealthAssessment item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCritical = item.vectorRisk == VectorRiskLevel.critical;
    final riskColor = isCritical
        ? const Color(0xFFFF5252)
        : (item.vectorRisk == VectorRiskLevel.moderate
            ? const Color(0xFFFFB300)
            : const Color(0xFF00E676));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: const Color(0xFF0F1E36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCritical
                ? const Color(0xFFFF5252).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          // Summary: always visible
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: riskColor,
            ),
          ),
          title: Text(
            item.locationSector,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: riskColor, width: 0.8),
                ),
                child: Text(
                  item.vectorRiskLabel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          iconColor: Colors.white38,
          collapsedIconColor: Colors.white38,
          // Detail: shown on tap
          children: [
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            // Metric pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetricPill('Peak',
                    '${item.peakFrequencyHz.toStringAsFixed(1)} Hz'),
                _buildMetricPill('Eco Score',
                    '${item.ecosystemIntegrityScore.toStringAsFixed(1)}/100'),
                _buildMetricPill(
                    'ID', item.id),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.plainLanguageExplanation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FHIR LOINC 96608-5',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
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
                  label: const Text('View FHIR',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildMetricPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
