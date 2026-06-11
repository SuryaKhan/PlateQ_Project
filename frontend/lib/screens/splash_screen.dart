import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Memberikan waktu loading palsu agar animasi loading terlihat elegan
    await Future.delayed(const Duration(seconds: 2));

    final profile = await AuthService.getProfile();

    if (!mounted) return;

    if (profile != null) {
      // Token valid, langsung ke MainScreen (Home)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Token tidak valid atau belum login, ke LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5), // Abu-abu muda
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  // Ikon pisau dan garpu
                  Icon(Icons.restaurant, size: 60, color: Color(0xFF1E293B)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Judul Plate'Q
            const Text(
              "Plate'Q",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "ARTISANAL RECIPES & FLAVORS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 50),

            // Loading Bar
            SizedBox(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFFD4D4D4),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "THE CULINARY CURATOR",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
