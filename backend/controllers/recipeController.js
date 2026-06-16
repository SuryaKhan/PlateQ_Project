const prisma = require('../db');

// --- 1. Fungsi Posting Resep (Sekarang Simpan Nama Foto) ---
const createRecipe = async (req, res) => {
  try {
    const { title, content, difficulty, cookingTime, category, categoryId } = req.body;
    const authorId = req.user.userId; 

    // Ambil nama file unik yang dibuat Multer
    // Kalau user nggak upload foto, nilainya jadi null
    const imageName = req.file ? req.file.filename : null;

    // Cek apakah category atau categoryId dikirim
    let categoryIdToSave = null;
    let inputCat = categoryId || category;
    if (inputCat && !isNaN(parseInt(inputCat))) {
      const parsedCatId = parseInt(inputCat);
      // Validasi apakah kategori ini benar-benar ada di database
      const categoryExists = await prisma.category.findUnique({
        where: { id: parsedCatId }
      });
      if (categoryExists) {
        categoryIdToSave = parsedCatId;
      }
    }

    const newRecipe = await prisma.recipe.create({
      data: { 
        title: title || "Resep Tanpa Judul", 
        content: content || "{}", 
        authorId,
        image: imageName,
        difficulty: difficulty || "Easy",
        cookingTime: cookingTime || "30 min",
        categoryId: categoryIdToSave // Gunakan relasi Category
      }
    });

    res.status(201).json({ message: "Resep + Foto berhasil diposting!", recipe: newRecipe });
  } catch (error) {
    console.log("Error Create:", error);
    res.status(500).json({ error: "Gagal memposting resep." });
  }
};

// --- 2. Fungsi Lihat Semua Resep (Dengan Filter) ---
const getAllRecipes = async (req, res) => {
  try {
    const { categoryId, search, authorId, page, limit } = req.query; // Tangkap parameter dari URL

    let filter = {};
    
    if (authorId) {
      filter.authorId = parseInt(authorId);
    }
    
    // Jika ada filter kategori
    if (categoryId) {
      filter.categoryId = parseInt(categoryId);
    }

    // Jika ada pencarian kata kunci di judul atau konten resep
    if (search) {
      filter.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { content: { contains: search, mode: 'insensitive' } }
      ];
    }

    const pageNum = parseInt(page) || 1;
    const takeNum = parseInt(limit) || 10;
    const skipNum = (pageNum - 1) * takeNum;

    const recipes = await prisma.recipe.findMany({
      where: filter,
      skip: skipNum,
      take: takeNum,
      include: {
        author: {
          select: { username: true, name: true, role: true, profileImage: true }
        },
        category: true, // Ambil detail kategori juga
        _count: { select: { likes: true, comments: true } }
      },
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json(recipes);
  } catch (error) {
    console.log("Error Get All:", error);
    res.status(500).json({ error: "Gagal mengambil data resep." });
  }
};

// --- 3. Fungsi Edit Resep (Update Foto Juga Bisa) ---
const updateRecipe = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, difficulty, cookingTime, category } = req.body;
    const userId = req.user.userId;

    const existingRecipe = await prisma.recipe.findUnique({ where: { id: parseInt(id) } });
    if (!existingRecipe) return res.status(404).json({ error: "Resep nggak ketemu bro!" });

    if (existingRecipe.authorId !== userId) {
      return res.status(403).json({ error: "Eits, nggak bisa edit resep orang lain!" });
    }

    // Cek kalau ada foto baru yang diupload pas edit
    const newImage = req.file ? req.file.filename : existingRecipe.image;

    let categoryIdToSave = existingRecipe.categoryId;
    if (category && !isNaN(parseInt(category))) {
      categoryIdToSave = parseInt(category);
    }

    const updatedRecipe = await prisma.recipe.update({
      where: { id: parseInt(id) },
      data: { 
        title, 
        content, 
        difficulty, 
        cookingTime, 
        categoryId: categoryIdToSave,
        image: newImage 
      }
    });

    res.json({ message: "Resep sukses diupdate!", recipe: updatedRecipe });
  } catch (error) {
    console.log("Error Update:", error);
    res.status(500).json({ error: "Gagal mengupdate resep." });
  }
};

// --- 4. Fungsi Hapus Resep ---
const deleteRecipe = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const existingRecipe = await prisma.recipe.findUnique({ where: { id: parseInt(id) } });
    if (!existingRecipe) return res.status(404).json({ error: "Resep nggak ketemu bro!" });

    if (existingRecipe.authorId !== userId) {
      return res.status(403).json({ error: "Eits, nggak bisa hapus resep orang lain!" });
    }

    await prisma.recipe.delete({ where: { id: parseInt(id) } });
    res.json({ message: "Resep berhasil dihapus!" });
  } catch (error) {
    console.log("Error Delete:", error);
    res.status(500).json({ error: "Gagal menghapus resep." });
  }
};

// --- 5. Fungsi Toggle Bookmark (Like) ---
const toggleBookmark = async (req, res) => {
  try {
    const { id } = req.params; // ID resep
    const userId = req.user.userId;

    const recipeId = parseInt(id);

    // Cek apakah resep ada
    const recipe = await prisma.recipe.findUnique({ where: { id: recipeId } });
    if (!recipe) return res.status(404).json({ error: "Resep tidak ditemukan!" });

    // Cek apakah user sudah bookmark
    const existingLike = await prisma.like.findUnique({
      where: {
        userId_recipeId: { userId, recipeId }
      }
    });

    if (existingLike) {
      // Jika sudah ada, hapus bookmark (Unlike)
      await prisma.like.delete({
        where: { id: existingLike.id }
      });
      res.json({ message: "Bookmark dihapus!", bookmarked: false });
    } else {
      // Jika belum ada, tambahkan bookmark (Like)
      await prisma.like.create({
        data: { userId, recipeId }
      });
      res.json({ message: "Resep dibookmark!", bookmarked: true });
    }
  } catch (error) {
    console.error("❌ ERROR TOGGLE BOOKMARK:", error);
    res.status(500).json({ error: "Gagal memproses bookmark." });
  }
};
// --- 6. Fitur Komentar ---
const addComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { text, parentId } = req.body;
    const userId = req.user.userId;

    const comment = await prisma.comment.create({
      data: {
        text,
        recipeId: parseInt(id),
        userId,
        parentId: parentId ? parseInt(parentId) : null
      },
      include: { user: { select: { name: true, username: true, profileImage: true } } }
    });
    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ error: "Gagal menambahkan komentar." });
  }
};

const getComments = async (req, res) => {
  try {
    const { id } = req.params;
    const comments = await prisma.comment.findMany({
      where: { 
        recipeId: parseInt(id),
        parentId: null // Hanya ambil parent comment (root)
      },
      include: { 
        user: { select: { name: true, username: true, profileImage: true } },
        replies: {
          include: { user: { select: { name: true, username: true, profileImage: true } } },
          orderBy: { createdAt: 'asc' } // Balasan urut dari lama ke baru
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    res.json(comments);
  } catch (error) {
    res.status(500).json({ error: "Gagal mengambil komentar." });
  }
};

module.exports = { createRecipe, getAllRecipes, updateRecipe, deleteRecipe, toggleBookmark, addComment, getComments };