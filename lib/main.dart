import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/shell/echostream_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EchoStreamApp()));
}

class EchoStreamApp extends StatelessWidget {
  const EchoStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoStream Sentinel',
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
      home: const EchoStreamShell(),
    );
  }
}
