import 'package:flutter/material.dart';
import '../../data/models/one_health_assessment.dart';

class TriadCard extends StatelessWidget {
  final OneHealthAssessment assessment;

  const TriadCard({
    super.key,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF14243D),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: Color(0xFF00E676),
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ONE HEALTH TRIAD SYNTHESIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  'IEEE OneAquaHealth 2026',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pillar 1: Ecosystem Integrity
                _buildPillarRow(
                  number: '1',
                  title: 'Freshwater Ecosystem Integrity',
                  scoreText: '${assessment.ecosystemIntegrityScore.toStringAsFixed(1)} / 100',
                  scoreColor: assessment.ecosystemIntegrityScore >= 70
                      ? const Color(0xFF00E676)
                      : (assessment.ecosystemIntegrityScore >= 45
                          ? const Color(0xFFFFB300)
                          : const Color(0xFFFF5252)),
                  icon: Icons.eco_rounded,
                  description: assessment.ecosystemSummary,
                  progressValue: assessment.ecosystemIntegrityScore / 100.0,
                ),
                const Divider(color: Colors.white10, height: 24),

                // Pillar 2: Vector Dynamics
                _buildPillarRow(
                  number: '2',
                  title: 'Vector Proliferation Dynamics',
                  scoreText: assessment.vectorRiskLabel,
                  scoreColor: assessment.vectorRisk == VectorRiskLevel.critical
                      ? const Color(0xFFFF5252)
                      : (assessment.vectorRisk == VectorRiskLevel.moderate
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF00E676)),
                  icon: Icons.pest_control_rounded,
                  description: assessment.vectorSummary,
                  progressValue: assessment.vectorOutbreakProbability,
                  isPercentage: true,
                ),
                const Divider(color: Colors.white10, height: 24),

                // Pillar 3: Human Well-being & Municipal Action
                _buildPillarRow(
                  number: '3',
                  title: 'Human Well-being & Public Health',
                  scoreText: assessment.humanRiskLabel,
                  scoreColor: assessment.humanWellbeingRisk ==
                          HumanWellbeingRiskLevel.severe
                      ? const Color(0xFFFF5252)
                      : (assessment.humanWellbeingRisk ==
                              HumanWellbeingRiskLevel.elevated
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF00E676)),
                  icon: Icons.local_hospital_rounded,
                  description: assessment.municipalActionRecommendation,
                  isActionRecommendation: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarRow({
    required String number,
    required String title,
    required String scoreText,
    required Color scoreColor,
    required IconData icon,
    required String description,
    double? progressValue,
    bool isPercentage = false,
    bool isActionRecommendation = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with number badge
        Row(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Score badge on its own line
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scoreColor, width: 0.8),
          ),
          child: Text(
            scoreText,
            style: TextStyle(
              color: scoreColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (progressValue != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: isActionRecommendation
                ? const Color(0xFFFFD54F)
                : Colors.white.withValues(alpha: 0.70),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
