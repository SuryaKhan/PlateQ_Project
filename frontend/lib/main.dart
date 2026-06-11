import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.loadTheme();
  runApp(const PlateQApp());
}

class PlateQApp extends StatelessWidget {
  const PlateQApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Plate'Q",
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FB),
            primaryColor: const Color(0xFF1E293B),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E293B),
              secondary: Color(0xFFB48A36), // Warna emas untuk tombol/aksen
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9FB),
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
            ),
            useMaterial3: false,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Navy Dark Background
            primaryColor: const Color(0xFF1E293B),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E293B),
              secondary: Color(0xFFB48A36), // Warna emas untuk tombol/aksen
              surface: Color(0xFF1E293B), // Card background di Dark Mode
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: false,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
