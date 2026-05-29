import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. TAMBAHIN CONTROLLER EMAIL DI SINI
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    // 2. PASTIKAN EMAIL JUGA GAK BOLEH KOSONG
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Isi formnya dulu bro!")));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password gak cocok bro!")));
      return;
    }

    setState(() => _isLoading = true);

    // 3. KIRIM _emailController.text KE BACKEND (Bukan string kosong "" lagi)
    bool success = await AuthService.register(
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil daftar! Silakan Login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Balik ke halaman login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal daftar. Email/Username mungkin sudah dipakai."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Start Your Culinary\nJourney",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Discover hand-picked recipes and curated dining experiences tailored for you.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // 4. TAMBAHIN KOLOM INPUT EMAIL DI SINI
            _inputField("Email Address", _emailController),
            const SizedBox(height: 15),

            _inputField("Username", _usernameController),
            const SizedBox(height: 15),
            _inputField("Password", _passwordController, isPass: true),
            const SizedBox(height: 15),
            _inputField(
              "Confirm Password",
              _confirmPasswordController,
              isPass: true,
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .grey, // Warnanya aku sesuaikan biar nyambung sama tema
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Daftar",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey, // Warna field-nya dicerahin dikit biar elegan
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
