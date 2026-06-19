import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'kitchen_welcome_screen.dart'; // Nanti kita buat
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.transparent;

  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.transparent;
      });
      return;
    }

    if (value.length < 8) {
      setState(() {
        _passwordStrengthText = 'Terlalu Pendek (Min. 8 karakter)';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    bool hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
    bool hasNumbers = RegExp(r'[0-9]').hasMatch(value);
    bool hasSpecials = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (hasLetters && hasNumbers && hasSpecials) {
      setState(() {
        _passwordStrengthText = 'Rumit 🔥';
        _passwordStrengthColor = Colors.green;
      });
    } else if ((hasLetters && hasNumbers) || (hasLetters && hasSpecials) || (hasNumbers && hasSpecials)) {
      setState(() {
        _passwordStrengthText = 'Oke 👍';
        _passwordStrengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrengthText = 'Low ⚠️';
        _passwordStrengthColor = Colors.redAccent;
      });
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Asumsi: AuthService.register sekarang menerima (name, email, username, password)
    // Tapi karena backend kita hanya butuh (email, username, password), kita bisa pakai email sebagai username juga untuk kemudahan sementara,
    // Atau ubah backend untuk terima name.
    // Sementara kita gunakan email bagian depan sebagai username.
    String username = _emailController.text.split('@')[0];

    bool success = await AuthService.register(
      _emailController.text,
      username,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Auto login agar token tersimpan
      bool loginSuccess = await AuthService.login(username, _passwordController.text);
      if (loginSuccess) {
         // Update profile untuk menyimpan Full Name
         await AuthService.updateProfile(_nameController.text, username, 'Halo, saya $username!', _emailController.text);
      }

      if (!mounted) return;
      // Navigasi ke Welcome to Kitchen Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const KitchenWelcomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pendaftaran gagal. Email mungkin sudah dipakai.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Account",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/LogoPlateQ.png', width: 120, height: 120, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Plate'Q",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const Text(
              "Your personal digital cookbook",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Form Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                  _buildTextField("Full Name", "Chef Gusteau", _nameController, validator: (val) {
                    if (val == null || val.isEmpty) return 'Nama wajib diisi';
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField("Email Address", "gusteau@curator.com", _emailController, validator: (val) {
                    if (val == null || val.isEmpty) return 'Email wajib diisi';
                    if (!val.contains('@')) return 'Format email tidak valid (harus ada @)';
                    return null;
                  }),
                  const SizedBox(height: 20),
                  _buildTextField("Password", "••••••••", _passwordController, obscureText: !_isPasswordVisible, onChanged: _checkPasswordStrength, validator: (val) {
                    if (val == null || val.isEmpty) return 'Password wajib diisi';
                    if (val.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  }, suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
                  if (_passwordStrengthText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _passwordStrengthText,
                          style: TextStyle(color: _passwordStrengthColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildTextField("Confirm Password", "••••••••", _confirmPasswordController, obscureText: !_isConfirmPasswordVisible, validator: (val) {
                    if (val == null || val.isEmpty) return 'Konfirmasi Password wajib diisi';
                    return null;
                  }, suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  )),
                  
                  const SizedBox(height: 32),

                  // Daftar Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Warna tombol abu-abu sesuai mockup
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Daftar",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                ],
               ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer Text
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already part of the kitchen? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
     ),
    ),
   );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.grey.shade200,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
