import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../scan/ui/screens/scan_screen.dart';
import '../scan/ui/screens/hitl_screen.dart';
import '../scan/ui/screens/one_health_screen.dart';
import '../scan/ui/screens/field_history_screen.dart';

class StreamcoyShell extends ConsumerStatefulWidget {
  const StreamcoyShell({super.key});

  @override
  ConsumerState<StreamcoyShell> createState() => _StreamcoyShellState();
}

class _StreamcoyShellState extends ConsumerState<StreamcoyShell> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScanScreen(onProceedToAnalysis: () => _navigateToIndex(1)),
      HitlScreen(onProceedToOneHealth: () => _navigateToIndex(2)),
      OneHealthScreen(onStartNewScan: () => _navigateToIndex(0)),
      const FieldHistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1526),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mic_none_rounded, color: Colors.white70),
              selectedIcon: Icon(Icons.mic_rounded, color: Color(0xFF00E5FF)),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_graph_rounded, color: Colors.white70),
              selectedIcon:
                  Icon(Icons.auto_graph_rounded, color: Color(0xFF00E5FF)),
              label: 'AI Review',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.hub_rounded, color: Color(0xFF00E5FF)),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, color: Colors.white70),
              selectedIcon:
                  Icon(Icons.history_rounded, color: Color(0xFF00E5FF)),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
