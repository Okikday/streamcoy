import 'package:flutter/material.dart';
import '../../data/models/hitl_validation_data.dart';

class HitlTriageWidget extends StatelessWidget {
  final HitlValidationData hitlData;
  final ValueChanged<HitlValidationData> onChanged;

  const HitlTriageWidget({
    super.key,
    required this.hitlData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF00E5FF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citizen Field Validation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Human-in-the-Loop confirmation (Track 3)',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question 1: Visual Sighting
          const Text(
            '1. Did you observe standing water or insect swarms?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Yes (Standing)',
                icon: Icons.water_rounded,
                selected:
                    hitlData.visualSighting == VisualSightingStatus.yesStandingWater,
                color: const Color(0xFFFF5252),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    visualSighting: VisualSightingStatus.yesStandingWater,
                  ),
                ),
              ),
              _buildChoiceChip(
                label: 'No (Flowing)',
                icon: Icons.waves_rounded,
                selected:
                    hitlData.visualSighting == VisualSightingStatus.noStandingWater,
                color: const Color(0xFF00E676),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    visualSighting: VisualSightingStatus.noStandingWater,
                  ),
                ),
              ),
              _buildChoiceChip(
                label: 'Unclear',
                icon: Icons.help_outline_rounded,
                selected:
                    hitlData.visualSighting == VisualSightingStatus.unclear,
                color: const Color(0xFFFFB300),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    visualSighting: VisualSightingStatus.unclear,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question 2: Stream Bank Morphology
          const Text(
            '2. Stream Bank Morphology:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: BankMorphology.naturalVegetated.label,
                icon: Icons.grass_rounded,
                selected: hitlData.bankMorphology ==
                    BankMorphology.naturalVegetated,
                color: const Color(0xFF00E676),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    bankMorphology: BankMorphology.naturalVegetated,
                  ),
                ),
              ),
              _buildChoiceChip(
                label: BankMorphology.moderateSlope.label,
                icon: Icons.landscape_rounded,
                selected: hitlData.bankMorphology ==
                    BankMorphology.moderateSlope,
                color: const Color(0xFFFFB300),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    bankMorphology: BankMorphology.moderateSlope,
                  ),
                ),
              ),
              _buildChoiceChip(
                label: BankMorphology.steepArtificial.label,
                icon: Icons.foundation_rounded,
                selected: hitlData.bankMorphology ==
                    BankMorphology.steepArtificial,
                color: const Color(0xFFFF5252),
                onTap: () => onChanged(
                  hitlData.copyWith(
                    bankMorphology: BankMorphology.steepArtificial,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question 3: Override Option
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hitlData.isFalsePositiveOverride
                  ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hitlData.isFalsePositiveOverride
                    ? const Color(0xFFFFB300)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mark as False Positive (Ambient Mechanical Hum)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Check if nearby air-conditioner, pump, or generator caused tone spike.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: hitlData.isFalsePositiveOverride,
                  activeThumbColor: const Color(0xFFFFB300),
                  onChanged: (val) => onChanged(
                    hitlData.copyWith(isFalsePositiveOverride: val),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.15),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : Colors.white60, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
