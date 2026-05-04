import 'package:flutter/material.dart';
import './screens/login_screen.dart';

void main() {
  runApp(const PlateQApp());
}

class PlateQApp extends StatelessWidget {
  const PlateQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Ngilangin pita "DEBUG" di pojok kanan atas
      title: "Plate'Q",
      theme: ThemeData(
        // Set tema warna utama biar nyambung sama desain abu-abu/monokrom lu
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      // Set halaman pertama yang muncul pas aplikasi dibuka
      home: const LoginScreen(),
    );
  }
}
