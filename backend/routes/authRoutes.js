const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);

module.exports = router;
const prisma = require('../db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken'); // Pastikan JWT udah di-import buat fitur Login

// ==========================================
// 1. FUNGSI UNTUK DAFTAR AKUN (REGISTER)
// ==========================================
exports.register = async (req, res) => {
  // Tangkap data dari Flutter (sekarang form-nya udah lengkap ada email)
  const { username, email, password } = req.body; 

  try {
    // Hash password biar aman kalau database dilihat orang lain
    const hashedPassword = await bcrypt.hash(password, 10); 

    // Simpan data lengkapnya ke PostgreSQL pakai Prisma
    const user = await prisma.user.create({
      data: {
        username,
        email,      // Kunci utamanya di sini: email akhirnya masuk!
        password: hashedPassword,
      },
    });

    res.status(201).json({ message: "Register sukses!" });
  } catch (error) {
    // Kalau error, terminal Node.js bakal ngasih tau detailnya (misal: email udah dipakai)
    console.error("❌ Error Detail dari Prisma pas Register:", error); 
    res.status(400).json({ error: "Gagal register. Username/Email mungkin sudah terdaftar." });
  }
};

// ==========================================
// 2. FUNGSI UNTUK MASUK APLIKASI (LOGIN)
// ==========================================
exports.login = async (req, res) => {
  const { username, password } = req.body;

  try {
    // Cari user di database berdasarkan username
    const user = await prisma.user.findUnique({
      where: { username },
    });

    // Kalau user-nya ternyata gak ada di database
    if (!user) {
      return res.status(401).json({ error: "Username tidak ditemukan." });
    }

    // Cocokkan password yang diketik dengan password yang di-hash di database
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Password salah bro!" });
    }

    // Bikin Tiket Masuk (Token JWT) kalau semuanya cocok
    // Catatan: 'rahasia_plateq_123' idealnya ditaruh di file .env pakai nama JWT_SECRET
    const token = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.JWT_SECRET || 'rahasia_plateq_123', 
      { expiresIn: '1d' } // Tiket hangus dalam 1 hari
    );

    // Kasih tokennya ke Flutter buat disimpen di brankas HP
    res.status(200).json({ message: "Login sukses!", token });
  } catch (error) {
    console.error("❌ Error Detail pas Login:", error);
    res.status(500).json({ error: "Server lagi bermasalah, coba lagi nanti." });
  }
};