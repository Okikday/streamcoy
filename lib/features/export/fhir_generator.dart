Map<String, dynamic> generateObservation({
  double? peakHz,
  required bool confirmed,
  required String bank,
}) {
  return {
    'resourceType': 'Observation',
    'id': 'echostream-obs-simulated',
    'status': 'final',
    'code': {
      'coding': [
        {
          'system': 'http://loinc.org',
          'code': '96608-5',
          'display': 'Environmental health and risk assessment panel',
        },
      ],
      'text': 'EchoStream One Health Assessment',
    },
    'effectiveDateTime': DateTime.now().toIso8601String(),
    'component': [
      {
        'code': {'text': 'Bioacoustic Mosquito Vector Probability'},
        'valueQuantity': {
          'value': peakHz != null
              ? (peakHz >= 450 && peakHz <= 650 ? 0.84 : 0.12)
              : 0.0,
          'unit': 'probability',
        },
      },
      {
        'code': {'text': 'Citizen Validation Status'},
        'valueString': confirmed
            ? 'Confirmed - Standing Water Observed'
            : 'Not Confirmed',
      },
      {
        'code': {'text': 'Acoustic Fundamental Frequency Peak'},
        'valueQuantity': {'value': peakHz},
      },
      {
        'code': {'text': 'Bank Condition'},
        'valueString': bank,
      },
    ],
  };
}
