import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/scan_pod.dart';
import '../../providers/scan_state.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/tilt_gauge_widget.dart';
import '../widgets/scenario_selector_sheet.dart';
import '../../../../core/ui/spacing.dart';
import '../../../../core/ui/section_header.dart';

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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'IEEE OneAquaHealth • On-Device Bioacoustics',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
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
        // Slim scenario strip as part of AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: _buildScenarioStrip(context, ref, state),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── RECORDING ZONE ──
              const SectionHeader(
                title: 'RECORDING',
                subtitle: 'Capture 30s of stream audio',
                icon: Icons.mic_rounded,
              ),

              // Countdown / Progress Gauge Card
              _buildCountdownProgressCard(context, ref, state),
              const SizedBox(height: AppSpacing.cardGap),

              // Dynamic Waveform Visualizer
              WaveformVisualizer(
                waveformSamples: state.recentWaveform,
                isRecording: state.isRecording,
                currentSamples: state.audioSamples.length,
                totalSamples: 480000,
              ),
              const SizedBox(height: AppSpacing.cardGap),

              // Primary Action Button (full-width, prominent)
              _buildPrimaryAction(context, ref, state),
              const SizedBox(height: AppSpacing.tightGap),

              // Secondary actions row
              _buildSecondaryActions(context, ref, state),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── DEVICE CALIBRATION ──
              // Only show expanded tilt gauge when recording; otherwise collapsed
              _buildCollapsibleTiltGauge(state, pod),

              // Post-Scan Analysis Prompt Banner (if audio captured)
              if (state.audioSamples.isNotEmpty && !state.isRecording) ...[
                const SizedBox(height: AppSpacing.cardGap),
                _buildAnalysisReadyCard(context, state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Slim inline scenario indicator under the AppBar.
  Widget _buildScenarioStrip(
      BuildContext context, WidgetRef ref, ScanState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1526),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: Color(0xFF00E5FF), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${state.selectedScenario.locationSector} • ${state.selectedScenario.title}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => _openScenarioSelector(context, ref),
            child: const Text(
              'Switch',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownProgressCard(
      BuildContext context, WidgetRef ref, ScanState state) {
    final progress = state.scanProgress;
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.innerCardPadding),
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
                    Flexible(
                      child: Text(
                        state.isRecording
                            ? 'Acoustic Scan Active'
                            : (state.audioSamples.isNotEmpty
                                ? 'Scan Buffer Complete'
                                : 'Ready for Protocol'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  state.isRecording
                      ? 'Holding at ${state.tiltDegrees.toStringAsFixed(0)}° towards riparian zone...'
                      : '30.0s 16 kHz Linear PCM buffer (480k samples).',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Primary CTA — full width, prominent.
  Widget _buildPrimaryAction(
      BuildContext context, WidgetRef ref, ScanState state) {
    final pod = ref.read(scanPodProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: state.isRecording
              ? const Color(0xFFFF5252)
              : const Color(0xFF00E5FF),
          foregroundColor:
              state.isRecording ? Colors.white : const Color(0xFF050B14),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
          state.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          size: 22,
        ),
        label: Text(
          state.isRecording ? 'Stop Recording' : 'Start 30s Field Scan',
        ),
      ),
    );
  }

  /// Secondary actions — Quick Demo + Reset in a subtle row below.
  Widget _buildSecondaryActions(
      BuildContext context, WidgetRef ref, ScanState state) {
    final pod = ref.read(scanPodProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed:
              state.isRecording ? null : () => pod.quickSimulateFullScan(),
          icon: const Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 16),
          label: Text(
            'Quick Demo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (state.audioSamples.isNotEmpty) ...[
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () => pod.resetScan(),
            icon: const Icon(Icons.refresh_rounded,
                size: 14, color: Colors.white54),
            label: const Text(
              'Reset Buffer',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  /// Tilt gauge — collapsible. Auto-shows when recording.
  Widget _buildCollapsibleTiltGauge(ScanState state, dynamic pod) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: state.isRecording
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'DEVICE CALIBRATION',
            subtitle: 'Stream bank angle',
            icon: Icons.screen_rotation_rounded,
          ),
          TiltGaugeWidget(
            tiltDegrees: state.tiltDegrees,
            onTiltChanged: (deg) => pod.setTiltDegrees(deg),
          ),
        ],
      ),
      // When not recording, show a compact expand-hint
      secondChild: Container(
        margin: const EdgeInsets.only(top: 4),
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            brightness: Brightness.dark,
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Icon(Icons.screen_rotation_rounded,
                    color: Colors.white.withValues(alpha: 0.45), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Device Calibration',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: state.isOptimalTilt
                        ? const Color(0xFF00E676).withValues(alpha: 0.15)
                        : const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.tiltDegrees.toStringAsFixed(0)}°',
                    style: TextStyle(
                      color: state.isOptimalTilt
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFFB300),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              TiltGaugeWidget(
                tiltDegrees: state.tiltDegrees,
                onTiltChanged: (deg) => pod.setTiltDegrees(deg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisReadyCard(BuildContext context, ScanState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.innerCardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.black, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acoustic Buffer Ready',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Peak: ${state.spectralResult.peakFrequencyHz.toStringAsFixed(1)} Hz • Ready for AI review',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: onProceedToAnalysis,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('View AI Review'),
            ),
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
