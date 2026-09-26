enum VisualSightingStatus {
  yesStandingWater,
  noStandingWater,
  unclear,
}

enum BankMorphology {
  naturalVegetated, // < 25 deg
  moderateSlope,    // 25 - 50 deg
  steepArtificial,  // > 50 deg
}

extension BankMorphologyExt on BankMorphology {
  String get label {
    switch (this) {
      case BankMorphology.naturalVegetated:
        return 'Natural Vegetated (<25°)';
      case BankMorphology.moderateSlope:
        return 'Moderate Slope (25-50°)';
      case BankMorphology.steepArtificial:
        return 'Steep Artificial / Concrete (>50°)';
    }
  }

  String get shortLabel {
    switch (this) {
      case BankMorphology.naturalVegetated:
        return 'Natural Vegetated';
      case BankMorphology.moderateSlope:
        return 'Moderate Slope';
      case BankMorphology.steepArtificial:
        return 'Steep Concrete';
    }
  }
}

class HitlValidationData {
  final VisualSightingStatus visualSighting;
  final BankMorphology bankMorphology;
  final bool isFalsePositiveOverride;
  final String notes;

  const HitlValidationData({
    this.visualSighting = VisualSightingStatus.yesStandingWater,
    this.bankMorphology = BankMorphology.naturalVegetated,
    this.isFalsePositiveOverride = false,
    this.notes = '',
  });

  HitlValidationData copyWith({
    VisualSightingStatus? visualSighting,
    BankMorphology? bankMorphology,
    bool? isFalsePositiveOverride,
    String? notes,
  }) {
    return HitlValidationData(
      visualSighting: visualSighting ?? this.visualSighting,
      bankMorphology: bankMorphology ?? this.bankMorphology,
      isFalsePositiveOverride:
          isFalsePositiveOverride ?? this.isFalsePositiveOverride,
      notes: notes ?? this.notes,
    );
  }
}
