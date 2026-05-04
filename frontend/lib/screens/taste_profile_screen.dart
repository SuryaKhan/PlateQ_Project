import 'package:flutter/material.dart';
import 'home_screen.dart'; // Nanti finish-nya ke sini

class TasteProfileScreen extends StatefulWidget {
  const TasteProfileScreen({super.key});

  @override
  State<TasteProfileScreen> createState() => _TasteProfileScreenState();
}

class _TasteProfileScreenState extends State<TasteProfileScreen> {
  // Simpan jawaban user di sini
  String _selectedSkill = "";
  String _selectedGoal = "";

  // Daftar pilihan
  final List<String> _skills = [
    "Pemula Banget",
    "Lumayan Bisa",
    "Calon MasterChef",
  ];
  final List<String> _goals = ["Masak Cepat", "Menu Hemat", "Makan Sehat"];

  void _finishProfile() {
    // Nanti di sini kamu bisa kirim data _selectedSkill & _selectedGoal ke API backend
    debugPrint("Skill: $_selectedSkill, Goal: $_selectedGoal");

    // Lanjut ke Beranda
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Taste Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biar Makin Pas!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Kasih tau kita sedikit tentang gaya masakmu.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Pertanyaan 1
            const Text(
              "1. Level skill masak kamu?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _skills
                  .map(
                    (skill) => _buildChip(
                      label: skill,
                      isSelected: _selectedSkill == skill,
                      onTap: () => setState(() => _selectedSkill = skill),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40),

            // Pertanyaan 2
            const Text(
              "2. Apa tujuan utama kamu?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _goals
                  .map(
                    (goal) => _buildChip(
                      label: goal,
                      isSelected: _selectedGoal == goal,
                      onTap: () => setState(() => _selectedGoal = goal),
                    ),
                  )
                  .toList(),
            ),

            const Spacer(),

            // Tombol Selesai
            ElevatedButton(
              onPressed: (_selectedSkill.isNotEmpty && _selectedGoal.isNotEmpty)
                  ? _finishProfile
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                disabledBackgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Selesai & Mulai Eksplorasi",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget custom untuk tombol pilihan (Chip)
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey : Colors.grey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
