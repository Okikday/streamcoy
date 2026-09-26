import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/tilt_gauge_widget.dart';
import '../widgets/scenario_selector_sheet.dart';

class ScanScreen extends ConsumerWidget {
  final VoidCallback onProceedToAnalysis;

  const ScanScreen({
    super.key,
    required this.onProceedToAnalysis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanPodProvider);
    final pod = ref.read(scanPodProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF070E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1526),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sensors_rounded,
                color: Color(0xFF00E5FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EchoStream Sentinel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'IEEE OneAquaHealth • On-Device Bioacoustics',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Acoustic Scenarios',
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _openScenarioSelector(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Scenario Banner
              _buildScenarioBanner(context, ref, state),
              const SizedBox(height: 14),

              // Countdown / Progress Gauge Card
              _buildCountdownProgressCard(context, ref, state),
              const SizedBox(height: 14),

              // Dynamic Waveform Visualizer
              WaveformVisualizer(
                waveformSamples: state.recentWaveform,
                isRecording: state.isRecording,
                currentSamples: state.audioSamples.length,
                totalSamples: 480000,
              ),
              const SizedBox(height: 14),

              // Device Incline Gauge (Riparian stream-bank sighting)
              TiltGaugeWidget(
                tiltDegrees: state.tiltDegrees,
                onTiltChanged: (deg) => pod.setTiltDegrees(deg),
              ),
              const SizedBox(height: 18),

              // Control Action Buttons
              _buildControlButtons(context, ref, state),
              const SizedBox(height: 14),

              // Post-Scan Analysis Prompt Banner (if audio captured)
              if (state.audioSamples.isNotEmpty && !state.isRecording) ...[
                _buildAnalysisReadyCard(context, state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioBanner(
      BuildContext context, WidgetRef ref, dynamic state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: Color(0xFF00E5FF), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedScenario.locationSector,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Environment: ${state.selectedScenario.title}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => _openScenarioSelector(context, ref),
            child: const Text(
              'Switch',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownProgressCard(
      BuildContext context, WidgetRef ref, dynamic state) {
    final progress = state.scanProgress;
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: state.isRecording
              ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.isRecording
                        ? const Color(0xFF00E5FF)
                        : (state.audioSamples.isNotEmpty
                            ? const Color(0xFF00E676)
                            : Colors.white24),
                  ),
                ),
                Text(
                  '${state.currentSeconds}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.isRecording
                          ? 'Acoustic Scan Active'
                          : (state.audioSamples.isNotEmpty
                              ? 'Scan Buffer Complete'
                              : 'Ready for Protocol'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  state.isRecording
                      ? 'Holding device at ${state.tiltDegrees.toStringAsFixed(0)}° towards riparian water zone...'
                      : 'Captures standardized 30.0s 16 kHz Linear PCM buffer (480k samples).',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
      BuildContext context, WidgetRef ref, dynamic state) {
    final pod = ref.read(scanPodProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.isRecording
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF00E5FF),
                  foregroundColor: state.isRecording
                      ? Colors.white
                      : const Color(0xFF050B14),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: state.isAnalyzing
                    ? null
                    : () {
                        if (state.isRecording) {
                          pod.stopScan();
                        } else {
                          pod.startScan(durationSeconds: 30);
                        }
                      },
                icon: Icon(
                  state.isRecording
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  size: 20,
                ),
                label: Text(
                  state.isRecording ? 'Stop Early' : 'Start 30s Field Scan',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: state.isRecording
                    ? null
                    : () => pod.quickSimulateFullScan(),
                icon: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFFFD54F),
                  size: 18,
                ),
                label: const Text(
                  'Quick Demo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        if (state.audioSamples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => pod.resetScan(),
              icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white54),
              label: const Text(
                'Reset Audio Buffer',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisReadyCard(BuildContext context, dynamic state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acoustic Buffer Evaluated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Peak: ${state.spectralResult.peakFrequencyHz.toStringAsFixed(1)} Hz • Ready for HITL review',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: onProceedToAnalysis,
            child: const Text('View AI Review'),
          ),
        ],
      ),
    );
  }

  void _openScenarioSelector(BuildContext context, WidgetRef ref) {
    final state = ref.read(scanPodProvider);
    final pod = ref.read(scanPodProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScenarioSelectorSheet(
        selectedScenario: state.selectedScenario,
        onScenarioSelected: (sc) => pod.setScenario(sc),
        customToneFreq: state.customToneFrequency,
        onCustomFreqChanged: (f) => pod.setCustomToneFrequency(f),
      ),
    );
  }
}
