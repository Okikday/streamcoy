import 'package:flutter/material.dart';
import '../../data/models/audio_scan_scenario.dart';

class ScenarioSelectorSheet extends StatelessWidget {
  final AudioScanScenario selectedScenario;
  final ValueChanged<AudioScanScenario> onScenarioSelected;
  final double customToneFreq;
  final ValueChanged<double> onCustomFreqChanged;

  const ScenarioSelectorSheet({
    super.key,
    required this.selectedScenario,
    required this.onScenarioSelected,
    required this.customToneFreq,
    required this.onCustomFreqChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Acoustic Field Scenarios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                ),
                child: const Text(
                  'Demo Sandbox',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Select a calibrated acoustic stream environment for rapid testing and hackathon evaluation:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ...AudioScanScenario.presets.map((scenario) {
            final isSelected = scenario.type == selectedScenario.type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () {
                  onScenarioSelected(scenario);
                  if (scenario.type != ScenarioType.customTone) {
                    Navigator.of(context).pop();
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                        : const Color(0xFF0F1E36),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00E5FF)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getScenarioIcon(scenario.type),
                        color: isSelected
                            ? const Color(0xFF00E5FF)
                            : Colors.white.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scenario.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              scenario.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00E5FF),
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (selectedScenario.type == ScenarioType.customTone) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14243D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tune Tone Frequency (Vector Peak):',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${customToneFreq.toStringAsFixed(0)} Hz',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: customToneFreq,
                    min: 350.0,
                    max: 750.0,
                    divisions: 80,
                    label: '${customToneFreq.toStringAsFixed(0)} Hz',
                    activeColor: const Color(0xFF00E5FF),
                    onChanged: onCustomFreqChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('350 Hz',
                          style: TextStyle(color: Colors.white38, fontSize: 10)),
                      Text('Critical: 450 - 650 Hz (Mosquito)',
                          style: TextStyle(
                              color: Color(0xFFFF8A80),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                      Text('750 Hz',
                          style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  IconData _getScenarioIcon(ScenarioType type) {
    switch (type) {
      case ScenarioType.stagnantCorridor:
        return Icons.pest_control_rounded;
      case ScenarioType.pristineBrook:
        return Icons.water_drop_rounded;
      case ScenarioType.urbanCulvert:
        return Icons.directions_car_rounded;
      case ScenarioType.customTone:
        return Icons.tune_rounded;
    }
  }
}
