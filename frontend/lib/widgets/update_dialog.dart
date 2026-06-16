import 'package:flutter/material.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, // Fix for Material 3 tinting
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Ilustrasi PlateQ (Custom Widget)
                  _buildIllustration(),
                  const SizedBox(height: 24),
                  // Judul
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: "🎉 "),
                        TextSpan(text: "Plate", style: TextStyle(color: Color(0xFFFF5252))),
                        TextSpan(text: "Q", style: TextStyle(color: Color(0xFF1E293B))),
                        TextSpan(text: " Baru Telah Hadir!"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Kami terus menyempurnakan PlateQ agar aktivitas berbagi dan mencoba resep menjadi lebih menyenangkan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  // Kotak "Apa yang ditingkatkan?"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5), // Light red/pink
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Apa yang ditingkatkan?",
                          style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.palette_outlined, Colors.deepOrange.shade100, Colors.deepOrange, "Tampilan lebih modern", "Desain baru yang lebih segar dan nyaman digunakan."),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.chat_bubble_outline, Colors.pink.shade100, Colors.pink, "Interaksi komunitas lebih lancar", "Fitur tanya jawab dan komentar lebih responsif."),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.bolt, Colors.orange.shade100, Colors.orange.shade800, "Waktu muat lebih cepat", "Navigasi aplikasi jadi lebih ringan dan efisien."),
                        const SizedBox(height: 16),
                        _buildFeatureItem(Icons.verified_user_outlined, Colors.green.shade100, Colors.green.shade700, "Perbaikan bug & stabilitas", "Aplikasi lebih stabil dan aman untuk digunakan."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Pesan Bawah
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: "Update sekarang dan nikmati pengalaman\n"),
                        TextSpan(text: "PlateQ", style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                        TextSpan(text: " yang lebih baik!"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Versi Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Versi 2.0.0",
                      style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFEBEB), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Nanti Saja", style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Simulasi update: Buka Play Store / App Store
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mengalihkan ke Play Store..."))
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5252),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Update Sekarang", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Tombol Close di Pojok Kanan Atas
          Positioned(
            right: 12,
            top: 12,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk List Fitur
  Widget _buildFeatureItem(IconData icon, Color bgColor, Color iconColor, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper untuk Ilustrasi PlateQ (Karena tidak ada gambar asli, kita buat mirip dengan Container & Icons)
  Widget _buildIllustration() {
    return SizedBox(
      height: 100,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Awan Kiri
          Positioned(
            left: 10,
            top: 20,
            child: Icon(Icons.cloud, color: Colors.orange.shade50, size: 40),
          ),
          // Awan Kanan
          Positioned(
            right: 10,
            top: 30,
            child: Icon(Icons.cloud, color: Colors.pink.shade50, size: 30),
          ),
          // Bintang
          Positioned(left: 30, top: 0, child: Icon(Icons.star, color: Colors.orange.shade200, size: 16)),
          Positioned(right: 30, bottom: 20, child: Icon(Icons.star, color: Colors.yellow.shade600, size: 12)),
          
          // Lingkaran PlateQ Tengah
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Q outline
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF5252), width: 6),
                  ),
                ),
                // Garis Q
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Transform.rotate(
                    angle: -0.785, // -45 degrees
                    child: Container(
                      width: 15,
                      height: 6,
                      color: const Color(0xFFFF5252),
                    ),
                  ),
                ),
                // Sendok & Garpu
                const Icon(Icons.restaurant, color: Color(0xFFFF5252), size: 24),
              ],
            ),
          ),
          
          // Alas (Podium)
          Positioned(
            bottom: 0,
            child: Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
