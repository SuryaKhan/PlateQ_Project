import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart'; //
import 'main_screen.dart'; //

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    bool success = await AuthService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal masuk. Cek username/password kamu.")),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Lupa Password?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Masukkan emailmu. Kami akan mengirimkan password baru."),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                isSending
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isEmpty) return;
                          
                          setStateDialog(() => isSending = true);
                          bool success = await AuthService.forgotPassword(emailController.text);
                          setStateDialog(() => isSending = false);
                          
                          if (!context.mounted) return;
                          Navigator.pop(context); // Tutup dialog
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success 
                                  ? "Password baru berhasil dikirim ke emailmu!" 
                                  : "Gagal mengirim email. Pastikan email terdaftar."
                              ),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Kirim", style: TextStyle(color: Colors.white)),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/images/LogoPlateQ.png', width: 120, height: 120, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Plate'Q",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Text(
                "Your personal digital cookbook",
                style: TextStyle(color: Colors.grey),
              ), //
              SizedBox(height: 40),

              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Username atau Email wajib diisi';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Username atau Email",
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Password wajib diisi';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.grey.shade200,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          "Forgot?",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.grey)
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              minimumSize: Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Daftar sekarang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
         ),
        ),
      ),
    );
  }
}
