import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _profileImage;
  
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
        _profileImage = data['profileImage'];
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');

        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('http://localhost:3000/api/users/upload-profile-image'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          pickedFile.path,
        ));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto profil berhasil diperbarui!")));
            _loadCurrentProfile(); // Reload to get the new image URL
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengupload foto.")));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;
    String strengthText = '';
    Color strengthColor = Colors.transparent;

    void checkStrength(String value, StateSetter setModalState) {
      if (value.isEmpty) {
        setModalState(() {
          strengthText = '';
          strengthColor = Colors.transparent;
        });
        return;
      }
      if (value.length < 8) {
        setModalState(() {
          strengthText = 'Terlalu Pendek (Min. 8 karakter)';
          strengthColor = Colors.red;
        });
        return;
      }
      bool hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
      bool hasNumbers = RegExp(r'[0-9]').hasMatch(value);
      bool hasSpecials = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

      if (hasLetters && hasNumbers && hasSpecials) {
        setModalState(() {
          strengthText = 'Rumit 🔥';
          strengthColor = Colors.green;
        });
      } else if ((hasLetters && hasNumbers) || (hasLetters && hasSpecials) || (hasNumbers && hasSpecials)) {
        setModalState(() {
          strengthText = 'Oke 👍';
          strengthColor = Colors.orange;
        });
      } else {
        setModalState(() {
          strengthText = 'Low ⚠️';
          strengthColor = Colors.redAccent;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Ubah Password", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password Lama", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    onChanged: (val) => checkStrength(val, setModalState),
                    decoration: const InputDecoration(labelText: "Password Baru", border: OutlineInputBorder()),
                  ),
                  if (strengthText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(strengthText, style: TextStyle(color: strengthColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                isLoading
                    ? const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                        onPressed: () async {
                          if (newPasswordController.text.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password baru minimal 8 karakter!"), backgroundColor: Colors.red));
                            return;
                          }

                          // Ambil state sebelum await
                          final nav = Navigator.of(context);
                          final scaffoldMsg = ScaffoldMessenger.of(context);

                          setModalState(() => isLoading = true);
                          bool success = await AuthService.changePassword(
                            _emailController.text,
                            oldPasswordController.text,
                            newPasswordController.text,
                          );
                          setModalState(() => isLoading = false);
                          
                          if (!mounted) return;
                          
                          nav.pop(); // Tutup dialog
                          if (success) {
                            scaffoldMsg.showSnackBar(const SnackBar(content: Text("Password berhasil diubah!"), backgroundColor: Colors.green));
                          } else {
                            scaffoldMsg.showSnackBar(const SnackBar(content: Text("Gagal mengubah password. Cek password lama!"), backgroundColor: Colors.red));
                          }
                        },
                        child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                      )
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
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
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImage != null 
                              ? NetworkImage('http://localhost:3000/uploads/$_profileImage') 
                              : null,
                          child: _profileImage == null 
                              ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37), // Gold premium color
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Ganti Foto Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                const SizedBox(height: 30),

                // Form Fields
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 5), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumTextField("Nama Lengkap", _nameController, Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildPremiumTextField("Username", _usernameController, Icons.alternate_email),
                      const SizedBox(height: 20),
                      _buildPremiumTextField("Bio", _bioController, Icons.info_outline, maxLines: 3),
                      const SizedBox(height: 20),
                      _buildPremiumTextField("Email Address", _emailController, Icons.email_outlined),
                      const SizedBox(height: 25),
                      // Tombol Ubah Password
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: Icon(Icons.lock_reset, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                          label: Text("Ubah Password Saat Ini", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Simpan Perubahan
                _isSaving 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B), // Warna dark modern
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF1E293B).withAlpha(100),
                      ),
                      child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                
                const SizedBox(height: 15),
                // Batal
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildPremiumTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : const Color(0xFFF8F9FB),
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
