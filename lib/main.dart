import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/shell/streamcoy_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: StreamcoyApp()));
}

/// Legacy alias for StreamcoyApp
typedef EchoStreamApp = StreamcoyApp;

class StreamcoyApp extends StatelessWidget {
  const StreamcoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamcoy',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070E1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5FF),
          onPrimary: const Color(0xFF050B14),
          secondary: const Color(0xFF00E676),
          onSecondary: Colors.black,
          error: const Color(0xFFFF5252),
          surface: const Color(0xFF0F1E36),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          // Screen / AppBar titles
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          // Card headings
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          // Card body text
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
          // Secondary / description text
          bodySmall: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.35,
          ),
          // AppBar subtitles, LOINC codes, minor labels
          labelSmall: TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          // Stat values / metrics
          labelLarge: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1526),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0F1E36),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: const Color(0xFF050B14),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0A1526),
          indicatorColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF00E5FF)
                  : Colors.white60,
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
      home: const StreamcoyShell(),
    );
  }
}
