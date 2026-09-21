import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/spectrogram_service.dart';
import '../widgets/spectrogram_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../export/fhir_generator.dart';

class ScanView extends ConsumerStatefulWidget {
  const ScanView({super.key});

  @override
  ConsumerState<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView> {
  List<double> _samples = [];
  List<List<double>> _frames = [];
  Timer? _timer;
  int _seconds = 0;
  bool _recording = false;

  // Simulate audio capture: produce a mixture with an optional mosquito tone near 540Hz
  void _startCapture({
    int duration = 30,
    int sampleRate = 16000,
    double toneFreq = 542,
  }) {
    _samples = [];
    _frames = [];
    _seconds = 0;
    _recording = true;
    final rng = Random();
    final totalSamples = duration * sampleRate;
    // produce incremental chunks per second
    var produced = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (produced >= totalSamples) {
        _stopCapture(sampleRate: sampleRate);
        return;
      }
      final chunk = <double>[];
      for (var i = 0; i < sampleRate; i++) {
        final tsec = (produced + i) / sampleRate;
        // base noise
        double s = rng.nextDouble() * 0.1 - 0.05;
        // add mosquito tone as a faint sine
        s += 0.2 * sin(2 * pi * toneFreq * tsec);
        chunk.add(s);
      }
      produced += sampleRate;
      _samples.addAll(chunk);
      setState(() {
        _seconds += 1;
      });
      // update spectrogram live (use shorter frame for responsiveness)
      _frames = computeSpectrogram(_samples, frameSize: 1024, hopSize: 512);
    });
  }

  void _stopCapture({int sampleRate = 16000}) {
    _timer?.cancel();
    _recording = false;
    // final spectrogram
    _frames = computeSpectrogram(_samples, frameSize: 2048, hopSize: 512);
    // analyze peak in last frame
    if (_frames.isNotEmpty) {
      final last = _frames.last;
      final peak = detectPeakFrequency(last, sampleRate, 2048);
      // if peak in mosquito band 450-650 -> mark detection
      final detected = (peak >= 450 && peak <= 650);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Scan Complete'),
          content: Text(
            'Peak frequency: ${peak.toStringAsFixed(1)} Hz\nPossible mosquito: ${detected ? 'Yes' : 'No'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _sighting = false;
  String _bank = 'Natural Vegetated';
  bool _falsePositive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EchoStream Scan')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      _recording ? 'Recording: $_seconds s' : 'Ready to scan',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: _frames.isEmpty
                          ? const Center(
                              child: Text('Spectrogram will appear here'),
                            )
                          : CustomPaint(
                              size: Size.infinite,
                              painter: SpectrogramPainter(_frames),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _recording
                              ? null
                              : () => _startCapture(duration: 30),
                          child: const Text('Start 30s Scan'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _recording ? _stopCapture : null,
                          child: const Text('Stop'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citizen Verification (Required):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    CheckboxListTile(
                      value: _sighting,
                      title: const Text(
                        'Confirmed standing water / swarm in immediate area',
                      ),
                      onChanged: (v) => setState(() => _sighting = v ?? false),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Bank Condition: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _bank,
                          items: const [
                            DropdownMenuItem(
                              value: 'Natural Vegetated',
                              child: Text('Natural Vegetated'),
                            ),
                            DropdownMenuItem(
                              value: 'Moderate Slope',
                              child: Text('Moderate Slope'),
                            ),
                            DropdownMenuItem(
                              value: 'Steep Artificial',
                              child: Text('Steep Artificial'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _bank = v ?? _bank),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _falsePositive,
                      title: const Text(
                        'Mark as false positive (ambient mechanical hum)',
                      ),
                      onChanged: (v) =>
                          setState(() => _falsePositive = v ?? false),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final fhir = generateObservation(
                              peakHz: _frames.isNotEmpty
                                  ? detectPeakFrequency(
                                      _frames.last,
                                      16000,
                                      2048,
                                    )
                                  : null,
                              confirmed: _sighting,
                              bank: _bank,
                            );
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('FHIR JSON'),
                                content: SingleChildScrollView(
                                  child: Text(fhir.toString()),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('View FHIR JSON'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            // placeholder submit
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Submitted (simulated)'),
                              ),
                            );
                          },
                          child: const Text('Submit to Hub'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
