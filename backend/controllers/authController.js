const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../db'); 

// ==========================================
// 1. FUNGSI DAFTAR (REGISTER)
// ==========================================
const register = async (req, res) => {
  try {
    // Ambil data lengkap dari Flutter
    const { username, password, name, email } = req.body;

    // Pastikan data penting nggak kosong sebelum diproses Prisma
    if (!username || !email || !password) {
      return res.status(400).json({ error: "Username, Email, dan Password wajib diisi!" });
    }

    // Hash password biar aman (standar industri)
    const hashedPassword = await bcrypt.hash(password, 10);

    // Simpan ke database PostgreSQL
    const newUser = await prisma.user.create({ 
      data: { 
        username, 
        email,
        password: hashedPassword, 
        // JURUS SAKTI: Kalau nama kosong dari Flutter, isi otomatis pakai Username
        // Ini biar gak kena error "Argument 'name' must not be null" lagi
        name: name || username 
      } 
    });

    res.status(201).json({ 
      message: "User berhasil dibuat!", 
      user: { id: newUser.id, username: newUser.username } 
    });

  } catch (error) { 
    // Console error ini bakal muncul di terminal Ubuntu/ThinkPad kamu
    console.error("❌ ERROR REGISTER:", error); 

    // Kasih pesan spesifik kalau username/email ternyata sudah ada
    if (error.code === 'P2002') {
      return res.status(400).json({ error: "Username atau Email sudah dipakai, coba yang lain!" });
    }

    res.status(400).json({ error: "Gagal register. Cek terminal backend!" }); 
  }
};

// ==========================================
// 2. FUNGSI MASUK (LOGIN)
// ==========================================
const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // 1. Cari user berdasarkan username
    const user = await prisma.user.findUnique({ where: { username } });
    if (!user) {
      return res.status(404).json({ error: "Username nggak ketemu!" });
    }

    // 2. Cek apakah password-nya cocok
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: "Password salah!" });
    }

    // 3. Buat Token JWT (Tiket masuk aplikasi)
    // Pakai secret dari .env atau fallback ke kata 'rahasia_plateq_2026'
    const token = jwt.sign(
      { userId: user.id, username: user.username }, 
      process.env.JWT_SECRET || 'rahasia_plateq_2026', 
      { expiresIn: '1d' } // Token berlaku 24 jam
    );

    res.json({ 
      message: "Login sukses!", 
      token,
      user: { id: user.id, username: user.username }
    });

  } catch (error) { 
    console.error("❌ ERROR LOGIN:", error);
    res.status(500).json({ error: "Terjadi kesalahan pada server." }); 
  }
};

// Export biar bisa dipanggil sama authRoutes.js
module.exports = { register, login };