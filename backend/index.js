const express = require('express');
const cors = require('cors');
const path = require('path'); // Tambahin ini buat urusan folder uploads
require('dotenv').config();

// 1. Import Rute
const authRoutes = require('./routes/authRoutes');
const recipeRoutes = require('./routes/recipeRoutes'); 
const userRoutes = require('./routes/userRoutes'); // <-- JANGAN LUPA INI!

const app = express();

// 2. Middleware
app.use(cors());
app.use(express.json());

// --- PENTING: Buka Akses Folder Uploads ---
// Biar Flutter bisa akses gambar via http://localhost:3000/uploads/nama_foto.jpg
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 3. Daftarkan Alamat API
app.get('/', (req, res) => res.json({ message: "Welcome to API Resep App bro!" }));

app.use('/api/auth', authRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/users', userRoutes); // <-- DAFTARKAN DI SINI BRO!

// 4. Nyalakan Server (HARUS PALING BAWAH)
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server backend udah nyala di http://localhost:${PORT}`);
});