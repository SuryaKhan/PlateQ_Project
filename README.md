# 📖 Panduan API Backend PlateQ (Untuk Frontend/Flutter)

Dokumen ini berisi daftar endpoint API yang sudah sesuai 100% dengan **Laporan PlateQ**. Silakan gunakan referensi ini untuk menghubungkan aplikasi Flutter dengan Backend.

Semua request yang membutuhkan autentikasi harus menyertakan Header:
`Authorization: Bearer <TOKEN_JWT_DARI_LOGIN>`

---

## 1. 🔐 Autentikasi (Login & Registrasi)
Sesuai dengan Alur *Sistem Autentikasi & Login Page*.

### A. Register Akun
- **URL**: `POST /api/auth/register`
- **Body (JSON)**:
  ```json
  {
    "username": "budi123",
    "password": "passwordrahasia",
    "email": "budi@gmail.com",
    "name": "Budi Santoso"
  }
  ```
- **Response Sukses (201)**: `{ "message": "User berhasil didaftarkan!" }`

### B. Login Akun
- **URL**: `POST /api/auth/login`
- **Body (JSON)**:
  ```json
  {
    "username": "budi123",
    "password": "passwordrahasia"
  }
  ```
- **Response Sukses (200)**: 
  Akan mengembalikan `token` JWT yang wajib disimpan di Flutter (menggunakan `shared_preferences` atau `secure_storage`).

---

## 2. 🌍 Eksplorasi Beranda & Resep
Sesuai dengan Alur *Eksplorasi (Mencari Resep)*.

### A. Ambil Semua Resep (Home Feed)
Bisa digunakan untuk mendapatkan semua resep, atau melakukan pencarian berdasarkan kata kunci & kategori.
- **URL**: `GET /api/recipes`
- **Query Params Opsional**:
  - `?search=ayam` (Untuk fitur pencarian kata kunci)
  - `?categoryId=1` (Untuk filter kategori)
- **Contoh URL**: `GET /api/recipes?search=nasi goreng`
- **Response Sukses (200)**: Mengembalikan Array kumpulan resep beserta info pembuatnya.

### B. Menambahkan ke Bookmark? (Ya/Tidak)
Sesuai dengan Alur *Bookmark* di halaman Detail Resep.
- **URL**: `POST /api/recipes/:id/bookmark` *(Contoh: `/api/recipes/5/bookmark`)*
- **Header**: `Authorization: Bearer <TOKEN>`
- **Response Sukses (200)**: 
  Sistem *toggle* pintar. Jika dipanggil saat belum dibookmark, maka akan jadi **Like**. Jika dipanggil lagi, maka akan jadi **Unlike**.
  ```json
  {
    "message": "Resep dibookmark!",
    "bookmarked": true
  }
  ```

---

## 3. 🍳 Kontribusi Resep (Tambah Konten)
Sesuai dengan Alur *Kontribusi Resep (Input Konten Baru)*.

### A. Upload Resep Baru
- **URL**: `POST /api/recipes`
- **Header**: `Authorization: Bearer <TOKEN>`
- **Format**: `Multipart/form-data` (Karena ada pengiriman Foto Makanan)
- **Fields**:
  - `title` (String) -> Judul Masakan
  - `content` (String) -> Daftar Bahan & Instruksi Memasak
  - `difficulty` (String) -> Misal: "Mudah", "Sedang"
  - `cookingTime` (String) -> Misal: "30 menit"
  - `categoryId` (Int) -> ID Kategori (Opsional)
  - `image` (File) -> Foto hasil masakan

---

## 4. 👤 Manajemen Profil (Taste Profile)
Sesuai dengan Alur *Manajemen Profil*.

### A. Dapatkan Detail Profil
Otomatis mengambil data User, Resep yang dia unggah, dan Resep yang dia Bookmark.
- **URL**: `GET /api/users/profile`
- **Header**: `Authorization: Bearer <TOKEN>`

### B. Edit Profil & Preferensi (Taste Profile)
- **URL**: `PUT /api/users/update-profile`
- **Header**: `Authorization: Bearer <TOKEN>`
- **Body (JSON)**:
  Bisa kirim field apa saja yang ingin diubah (bersifat opsional): `name, bio, preferences, username, email, phone, profileImage`.

---

## Catatan Tambahan untuk UI Developer (Temanmu):
1. **Menampilkan Gambar:** Gambar yang diupload dari resep disimpan di folder `/uploads`. Untuk menampilkannya di UI Flutter, cukup panggil *base URL* ditambah nama filenya: `http://<IP_KITA>:3000/uploads/nama_file.jpg`.
2. Semua fitur yang disebutkan di laporan sudah terakomodasi di dalam *endpoint-endpoint* di atas. Selamat ngoding! 💻
