import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(PlateQApp());
}

class PlateQApp extends StatelessWidget {
  const PlateQApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Plate'Q",
      theme: ThemeData(primarySwatch: Colors.grey),
      home: LoginScreen(), // Jadikan LoginScreen sebagai halaman utama
    );
  }
}
