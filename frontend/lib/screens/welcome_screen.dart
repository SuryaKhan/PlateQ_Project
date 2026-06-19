import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'taste_profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar/Ilustrasi Header
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/400x200'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Welcome to the Kitchen!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ), //
            SizedBox(height: 15),
            Text(
              "Your journey to culinary discovery starts now. Let's get cooking!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ), //
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Start Exploring →",
                style: TextStyle(color: Colors.white),
              ), //
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Sekarang import-nya jadi kepakai karena dipanggil di sini!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TasteProfileScreen(),
                  ),
                );
              },
              child: Text(
                "Complete your taste profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
