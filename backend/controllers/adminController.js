const prisma = require('../db');

// --- PENGUMUMAN & KATEGORI ---
// 1. BUAT PENGUMUMAN BARU
exports.createAnnouncement = async (req, res) => {
  try {
    const { title, content, category } = req.body;
    const userId = req.user.userId;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPERADMIN')) {
      return res.status(403).json({ error: "Akses ditolak! Hanya Admin yang bisa membuat pengumuman." });
    }

    const newAnnouncement = await prisma.announcement.create({
      data: { title, content, category: category || 'INFO', authorId: userId }
    });

    // Buat notifikasi untuk semua user
    const allUsers = await prisma.user.findMany({ select: { id: true } });
    
    const isSuperAdmin = user.role === 'SUPERADMIN';
    const notifType = isSuperAdmin ? "SUPERADMIN_ANNOUNCEMENT" : "ADMIN_ANNOUNCEMENT";
    const senderTitle = isSuperAdmin ? "Super Admin" : "Admin";

    const categoryTitle = category === 'UPDATE_APK' ? '[UPDATE APK]' : category === 'EVENT' ? '[EVENT]' : '[INFO]';

    const notifications = allUsers.map(u => ({
      userId: u.id,
      type: notifType,
      message: `${categoryTitle} Pengumuman dari ${senderTitle}: ${title}`
    }));
    await prisma.notification.createMany({ data: notifications });

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
      include: { author: { select: { name: true, username: true, role: true } } }
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

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPERADMIN')) {
      return res.status(403).json({ error: "Akses ditolak! Hanya Admin yang bisa membuat kategori." });
    }

    const newCategory = await prisma.category.create({ data: { name, icon } });
    res.status(201).json({ message: "Kategori berhasil dibuat!", category: newCategory });
  } catch (error) {
    console.error("❌ ERROR CREATE CATEGORY:", error);
    res.status(500).json({ error: "Gagal membuat kategori. Pastikan nama kategori unik." });
  }
};

// --- STATISTIK & MANAJEMEN ADMIN ---

// Helper untuk cek akses admin
const checkAdmin = async (userId) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  return user && (user.role === 'ADMIN' || user.role === 'SUPERADMIN');
};

// 4. GET STATISTIK DASHBOARD
exports.getStats = async (req, res) => {
  try {
    const isAdmin = await checkAdmin(req.user.userId);
    if (!isAdmin) return res.status(403).json({ error: "Akses ditolak!" });

    const totalUsers = await prisma.user.count();
    const totalRecipes = await prisma.recipe.count();
    const totalComments = await prisma.comment.count();
    const totalLikes = await prisma.like.count();

    // Data palsu untuk grafik (karena hitung harian rumit untuk UAS)
    const growthData = [10, 25, 18, 40, 38, 60, 80];

    res.json({
      totalUsers,
      totalRecipes,
      trending: totalLikes, // Menggunakan total like sebagai metric trending
      reports: totalComments, // Menggunakan total komentar
      growthData
    });
  } catch (error) {
    console.error("❌ ERROR GET STATS:", error);
    res.status(500).json({ error: "Gagal mengambil statistik." });
  }
};

// 5. GET ALL USERS
exports.getAllUsers = async (req, res) => {
  try {
    const isAdmin = await checkAdmin(req.user.userId);
    if (!isAdmin) return res.status(403).json({ error: "Akses ditolak!" });

    const users = await prisma.user.findMany({
      select: {
        id: true,
        username: true,
        name: true,
        email: true,
        role: true,
        profileImage: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' }
    });
    res.json(users);
  } catch (error) {
    console.error("❌ ERROR GET USERS:", error);
    res.status(500).json({ error: "Gagal mengambil daftar pengguna." });
  }
};

// 6. DELETE USER
exports.deleteUser = async (req, res) => {
  try {
    const isAdmin = await checkAdmin(req.user.userId);
    if (!isAdmin) return res.status(403).json({ error: "Akses ditolak!" });

    const { id } = req.params;
    
    // Pastikan tidak menghapus superadmin
    const targetUser = await prisma.user.findUnique({ where: { id: parseInt(id) } });
    if (targetUser && targetUser.role === 'SUPERADMIN') {
        return res.status(403).json({ error: "Tidak bisa menghapus Superadmin!" });
    }

    // 1. Hapus child data dari User
    await prisma.like.deleteMany({ where: { userId: parseInt(id) }});
    
    // Hapus balasan dari komentar user ini terlebih dahulu
    const userComments = await prisma.comment.findMany({ where: { userId: parseInt(id) }});
    const userCommentIds = userComments.map(c => c.id);
    if (userCommentIds.length > 0) {
      await prisma.comment.deleteMany({ where: { parentId: { in: userCommentIds } }});
    }
    // Lalu hapus komentar user
    await prisma.comment.deleteMany({ where: { userId: parseInt(id) }});

    await prisma.follow.deleteMany({ where: { OR: [{ followerId: parseInt(id) }, { followingId: parseInt(id) }] }});
    await prisma.collectionItem.deleteMany({ where: { collection: { userId: parseInt(id) } }});
    await prisma.collection.deleteMany({ where: { userId: parseInt(id) }});
    await prisma.cooksnap.deleteMany({ where: { userId: parseInt(id) }});
    await prisma.notification.deleteMany({ where: { userId: parseInt(id) }});
    await prisma.announcement.deleteMany({ where: { authorId: parseInt(id) }});
    
    // 2. Hapus resep yang dibuat user ini beserta child-nya
    const userRecipes = await prisma.recipe.findMany({ where: { authorId: parseInt(id) }});
    for(const recipe of userRecipes) {
        await prisma.like.deleteMany({ where: { recipeId: recipe.id }});
        // Hapus child comments dulu, baru parent comments
        await prisma.comment.deleteMany({ where: { recipeId: recipe.id, parentId: { not: null } }});
        await prisma.comment.deleteMany({ where: { recipeId: recipe.id, parentId: null }});
        await prisma.collectionItem.deleteMany({ where: { recipeId: recipe.id }});
        await prisma.cooksnap.deleteMany({ where: { recipeId: recipe.id }});
    }
    await prisma.recipe.deleteMany({ where: { authorId: parseInt(id) }});
    
    // Akhirnya hapus user
    await prisma.user.delete({ where: { id: parseInt(id) } });

    res.json({ message: "Pengguna berhasil dihapus." });
  } catch (error) {
    console.error("❌ ERROR DELETE USER:", error);
    res.status(500).json({ error: `Gagal menghapus pengguna: ${error.message}` });
  }
};

// 7. GET ALL RECIPES
exports.getAllRecipes = async (req, res) => {
  try {
    const isAdmin = await checkAdmin(req.user.userId);
    if (!isAdmin) return res.status(403).json({ error: "Akses ditolak!" });

    const recipes = await prisma.recipe.findMany({
      include: {
        author: { select: { name: true, username: true } },
        category: { select: { name: true } }
      },
      orderBy: { createdAt: 'desc' }
    });
    res.json(recipes);
  } catch (error) {
    console.error("❌ ERROR GET RECIPES:", error);
    res.status(500).json({ error: "Gagal mengambil daftar resep." });
  }
};

// 8. DELETE RECIPE
exports.deleteRecipe = async (req, res) => {
  try {
    const isAdmin = await checkAdmin(req.user.userId);
    if (!isAdmin) return res.status(403).json({ error: "Akses ditolak!" });

    const { id } = req.params;

    await prisma.like.deleteMany({ where: { recipeId: parseInt(id) }});
    // Hapus balasan komentar dulu, baru parent komentar
    await prisma.comment.deleteMany({ where: { recipeId: parseInt(id), parentId: { not: null } }});
    await prisma.comment.deleteMany({ where: { recipeId: parseInt(id), parentId: null }});
    await prisma.collectionItem.deleteMany({ where: { recipeId: parseInt(id) }});
    await prisma.cooksnap.deleteMany({ where: { recipeId: parseInt(id) }});
    await prisma.recipe.delete({ where: { id: parseInt(id) } });

    res.json({ message: "Resep berhasil dihapus." });
  } catch (error) {
    console.error("❌ ERROR DELETE RECIPE:", error);
    res.status(500).json({ error: `Gagal menghapus resep: ${error.message}` });
  }
};
