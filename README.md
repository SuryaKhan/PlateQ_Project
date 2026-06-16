# 🍳 PlateQ - Your Personal Digital Cookbook

Selamat datang di repositori resmi **PlateQ**! Aplikasi resep makanan digital revolusioner yang dirancang khusus untuk memenuhi tugas dan menyajikan antarmuka super elegan ala chef bintang lima.

Proyek ini telah melalui serangkaian proses uji TDD (Test-Driven Development) ketat baik di sisi Frontend (Flutter) maupun Backend (Node.js) sehingga dijamin 100% bebas hambatan.

---

## 🚀 Panduan Deployment & Instalasi (Untuk Roy, Adha, & Dosen)

Bagi teman-teman *Developer* atau Dosen Penguji yang ingin mengetes aplikasi secara penuh hingga menjadi format `.apk`, silakan ikuti petunjuk berikut:

### 1. Menyalakan Backend (Server API) di Render.com
Karena aplikasi ini *online*, backend harus dihidupkan 24 jam agar aplikasi di HP kalian bisa terkoneksi dengan database Supabase.
1. Buka [Render.com](https://render.com) dan login via GitHub.
2. Buat **New Web Service** dan pilih repositori `PlateQ_Project` ini.
3. Atur spesifikasi *build*:
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `node index.js`
4. Di bagian **Environment Variables**, tambahkan:
   - `DATABASE_URL` = `<ISI_DENGAN_DATABASE_URL_SUPABASE_KAMU>`
   - `DIRECT_URL` = `<ISI_DENGAN_DIRECT_URL_SUPABASE_KAMU>`
   - `JWT_SECRET` = `<ISI_DENGAN_KODE_RAHASIA_BEBAS>`
5. Klik **Create** dan tunggu hingga statusnya berwarna hijau (*Live*). Jangan lupa *copy* URL publik yang muncul (misal: `https://plateq-api.onrender.com`).

### 2. Menyambungkan Frontend & Membuat APK
1. Buka folder `frontend/lib/services/`.
2. Ubah URL `localhost` menjadi URL publik Render yang baru saja kalian dapatkan.
3. Buka terminal komputer kalian dan ketik perintah berikut untuk mencetak aplikasi Android:
   ```bash
   cd frontend
   flutter build apk --release
   ```
4. Kirim file APK yang ada di folder `frontend/build/app/outputs/flutter-apk/app-release.apk` ke HP Android Dosen/Tim.

### 3. Akun Testing Rahasia (Superadmin)
Untuk mengetes fitur Dasbor Admin (Membuat Pengumuman/Pop-up Update APK, dsb), kalian bisa login menggunakan akun rahasia ini di dalam aplikasi:
- **Username:** `superadmin`
- **Password:** `plateq2026!`

---

## 📖 Panduan API Backend Lengkap (Referensi Developer)

Dokumen ini berisi daftar endpoint API yang sudah sesuai 100% dengan **Laporan PlateQ**. Silakan gunakan referensi ini untuk menghubungkan aplikasi Flutter dengan Backend jika kalian ingin memodifikasinya lebih lanjut.

Semua request yang membutuhkan autentikasi harus menyertakan Header:
`Authorization: Bearer <TOKEN_JWT_DARI_LOGIN>`

### 1. 🔐 Autentikasi (Login & Registrasi)
* **Register:** `POST /api/auth/register`
  * Body: `{ "username": "budi123", "password": "passwordrahasia", "email": "budi@gmail.com", "name": "Budi Santoso" }`
* **Login:** `POST /api/auth/login`
  * Body: `{ "username": "budi123", "password": "passwordrahasia" }`

### 2. 🌍 Eksplorasi Beranda & Resep
* **Ambil Semua Resep:** `GET /api/recipes?search=ayam&categoryId=1`
* **Bookmark/Like Resep:** `POST /api/recipes/:id/bookmark`

### 3. 🍳 Kontribusi Resep (Tambah Konten)
* **Upload Resep Baru:** `POST /api/recipes` (Multipart/form-data)
  * Membutuhkan field: `title`, `content`, `difficulty`, `cookingTime`, `categoryId`, dan foto makanan di field `image`.

### 4. 👥 Fitur Sosial
* **Follow/Unfollow User:** `POST /api/social/follow/:id`
* **Cek Notifikasi:** `GET /api/social/notifications`
* **Baca Notifikasi:** `PUT /api/social/notifications/read`
* **Bagikan Cooksnap (Hasil Masak):** `POST /api/social/recipes/:recipeId/cooksnaps` (Multipart/form-data)

### 5. 👑 Fitur Admin (Khusus Role ADMIN/SUPERADMIN)
* **Dashboard Statistik:** `GET /api/admin/stats`
* **Kirim Pengumuman Pop-up:** `POST /api/admin/announcements`
  * Body: `{ "title": "Update V2", "content": "Mohon update aplikasi", "category": "UPDATE_APK" }`
* **Manajemen Pengguna (Banned):** `DELETE /api/admin/users/:id`

### 6. 👤 Manajemen Profil (Taste Profile)
* **Dapatkan Detail Profil (Diri Sendiri):** `GET /api/users/profile`
* **Edit Profil:** `PUT /api/users/update-profile`

---
*Happy Coding & Happy Cooking!* 🍳💻
