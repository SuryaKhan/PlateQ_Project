import 'package:flutter/material.dart';
import 'main_screen.dart';

class KitchenWelcomeScreen extends StatelessWidget {
  const KitchenWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Plate'Q",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1556910103-1c02745a872f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3', // Kitchen image placeholder
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),

              // Title
              const Text(
                "Welcome to the\nKitchen!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your journey to culinary discovery starts now. Let's get cooking!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              // Start Exploring Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF94A3B8), // Warna abu-abu kebiruan
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Start Exploring",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Complete Profile Text
              GestureDetector(
                onTap: () {
                  // Nanti bisa diarahkan ke Edit Profile
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: const Text(
                  "Complete your taste profile",
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Feature Cards
              _buildFeatureCard(
                Icons.restaurant_menu,
                "Plates",
                "Access 10,000+ chef-vetted recipes tailored to your pantry.",
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                Icons.people_outline,
                "Chef Community",
                "Connect with culinary experts and home cooks worldwide.",
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                Icons.auto_awesome,
                "Smart Planner",
                "Let AI create personalized meal plans based on your goals.",
              ),
              
              const SizedBox(height: 40),

              // Verified Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "ACCOUNT VERIFIED",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFBDBDBD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
