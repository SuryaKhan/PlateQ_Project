const prisma = require('../db');

// --- 1. Fungsi Posting Resep (Sekarang Simpan Nama Foto) ---
const createRecipe = async (req, res) => {
  try {
    const { title, content, difficulty, cookingTime, category } = req.body;
    const authorId = req.user.userId; 

    // Ambil nama file unik yang dibuat Multer
    // Kalau user nggak upload foto, nilainya jadi null
    const imageName = req.file ? req.file.filename : null;

    const newRecipe = await prisma.recipe.create({
      data: { 
        title, 
        content, 
        authorId,
        image: imageName, // <--- Nama file disimpan di kolom image
        difficulty: difficulty || "Easy",
        cookingTime: cookingTime || "30 min",
        category: category || "General"
      }
    });

    res.status(201).json({ message: "Resep + Foto berhasil diposting!", recipe: newRecipe });
  } catch (error) {
    console.log("Error Create:", error);
    res.status(500).json({ error: "Gagal memposting resep." });
  }
};

// --- 2. Fungsi Lihat Semua Resep ---
const getAllRecipes = async (req, res) => {
  try {
    const recipes = await prisma.recipe.findMany({
      include: {
        author: {
          select: { username: true, name: true }
        }
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

    const updatedRecipe = await prisma.recipe.update({
      where: { id: parseInt(id) },
      data: { 
        title, 
        content, 
        difficulty, 
        cookingTime, 
        category,
        image: newImage // <--- Update fotonya
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

module.exports = { createRecipe, getAllRecipes, updateRecipe, deleteRecipe };