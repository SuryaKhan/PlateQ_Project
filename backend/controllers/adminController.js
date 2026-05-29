const prisma = require('../db');

// 1. BUAT PENGUMUMAN BARU
exports.createAnnouncement = async (req, res) => {
  try {
    const { title, content } = req.body;
    const userId = req.user.userId;

    // Pastikan user adalah Admin atau Superadmin
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPERADMIN')) {
      return res.status(403).json({ error: "Akses ditolak! Hanya Admin yang bisa membuat pengumuman." });
    }

    const newAnnouncement = await prisma.announcement.create({
      data: {
        title,
        content,
        authorId: userId
      }
    });

    res.status(201).json({ message: "Pengumuman berhasil dibuat!", announcement: newAnnouncement });
  } catch (error) {
    console.error("❌ ERROR CREATE ANNOUNCEMENT:", error);
    res.status(500).json({ error: "Gagal membuat pengumuman." });
  }
};

// 2. DAPATKAN SEMUA PENGUMUMAN
exports.getAnnouncements = async (req, res) => {
  try {
    const announcements = await prisma.announcement.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          select: { name: true, username: true, role: true }
        }
      }
    });

    res.json(announcements);
  } catch (error) {
    console.error("❌ ERROR GET ANNOUNCEMENTS:", error);
    res.status(500).json({ error: "Gagal mengambil daftar pengumuman." });
  }
};

// 3. TAMBAH KATEGORI BARU
exports.createCategory = async (req, res) => {
  try {
    const { name, icon } = req.body;
    const userId = req.user.userId;

    // Pastikan user adalah Admin atau Superadmin
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPERADMIN')) {
      return res.status(403).json({ error: "Akses ditolak! Hanya Admin yang bisa membuat kategori." });
    }

    const newCategory = await prisma.category.create({
      data: { name, icon }
    });

    res.status(201).json({ message: "Kategori berhasil dibuat!", category: newCategory });
  } catch (error) {
    console.error("❌ ERROR CREATE CATEGORY:", error);
    res.status(500).json({ error: "Gagal membuat kategori. Pastikan nama kategori unik." });
  }
};
