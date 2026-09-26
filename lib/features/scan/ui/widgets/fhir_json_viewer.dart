import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/one_health_assessment.dart';
import '../../../export/fhir_bundle_builder.dart';

class FhirJsonViewer extends StatefulWidget {
  final OneHealthAssessment assessment;

  const FhirJsonViewer({
    super.key,
    required this.assessment,
  });

  static void show(BuildContext context, OneHealthAssessment assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FhirJsonViewer(assessment: assessment),
    );
  }

  @override
  State<FhirJsonViewer> createState() => _FhirJsonViewerState();
}

class _FhirJsonViewerState extends State<FhirJsonViewer> {
  bool _copied = false;
  bool _showBundle = false;

  @override
  Widget build(BuildContext context) {
    final jsonMap = _showBundle
        ? FhirBundleBuilder.buildBundle(widget.assessment)
        : FhirBundleBuilder.buildObservation(widget.assessment);
    final jsonString = FhirBundleBuilder.formatJson(jsonMap);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF091220),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.code_rounded,
                            color: Color(0xFF00E5FF), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'HL7 FHIR R4 Resource',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track 7: Digital Health Standard (LOINC 96608-5)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                // Toggle between Observation and Bundle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Observation', style: TextStyle(fontSize: 10)),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Bundle', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                  selected: {_showBundle},
                  onSelectionChanged: (set) {
                    setState(() => _showBundle = set.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Code Display Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF050B14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    color: Color(0xFF80D8FF),
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: _copied
                            ? const Color(0xFF00E676)
                            : Colors.white.withValues(alpha: 0.25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: jsonString));
                      setState(() => _copied = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _copied = false);
                      });
                    },
                    icon: Icon(
                      _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                      color: _copied
                          ? const Color(0xFF00E676)
                          : const Color(0xFF00E5FF),
                      size: 16,
                    ),
                    label: Text(_copied ? 'Copied to Clipboard' : 'Copy FHIR JSON'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: const Color(0xFF050B14),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF00E676),
                          content: Row(
                            children: const [
                              Icon(Icons.cloud_done_rounded,
                                  color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'FHIR Observation ingested into Municipal Sentinel Registry',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Export to Registry'),
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
