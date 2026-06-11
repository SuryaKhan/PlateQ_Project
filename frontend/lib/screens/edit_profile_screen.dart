import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() async {
    final data = await AuthService.getProfile();
    if (data != null && mounted) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _emailController.text = data['email'] ?? '';
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data profil saat ini.")),
        );
      }
    }
  }

  void _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    bool success = await AuthService.updateProfile(
      _nameController.text,
      _usernameController.text,
      _bioController.text,
      _emailController.text,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui profil."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto Profil Placeholder
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Ganti Foto Profil", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // Form Fields
                _buildTextField("Nama", _nameController),
                const SizedBox(height: 20),
                _buildTextField("Username", _usernameController),
                const SizedBox(height: 20),
                _buildTextField("Bio", _bioController, maxLines: 3),
                const SizedBox(height: 20),
                _buildTextField("Email Address", _emailController),
                
                const SizedBox(height: 40),
                
                // Simpan Perubahan
                _isSaving 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF94A3B8), // Warna biru keabuan
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                
                const SizedBox(height: 15),
                // Batal
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
