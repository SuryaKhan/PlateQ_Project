const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { createRecipe, getAllRecipes, updateRecipe, deleteRecipe, toggleBookmark, addComment, getComments, deleteComment } = require('../controllers/recipeController');
const authenticateToken = require('../middleware/authMiddleware');

// --- PENGATURAN PENYIMPANAN GAMBAR ---
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // File disimpan di folder uploads/
  },
  filename: (req, file, cb) => {
    // Nama file: tanggal-angkaacak.ekstensi
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// --- ROUTES ---
router.get('/', getAllRecipes);
router.get('/seed-categories', async (req, res) => {
  const prisma = require('../db');
  await prisma.category.createMany({
    data: [
      { id: 1, name: 'Nasi' },
      { id: 2, name: 'Mie' },
      { id: 3, name: 'Minuman' },
      { id: 4, name: 'Dessert' }
    ],
    skipDuplicates: true
  });
  await prisma.recipe.updateMany({ data: { categoryId: 1 } });
  res.json({ message: 'Seeded!' });
});

// Tambahkan upload.single('image') di sini. 'image' adalah nama field dari Flutter nanti
router.post('/', authenticateToken, upload.single('image'), createRecipe);

router.put('/:id', authenticateToken, upload.single('image'), updateRecipe); 
router.delete('/:id', authenticateToken, deleteRecipe); 

// Bookmark (Like/Unlike)
router.post('/:id/bookmark', authenticateToken, toggleBookmark);

// Comments
router.get('/:id/comments', getComments);
router.post('/:id/comments', authenticateToken, addComment);
router.delete('/:id/comments/:commentId', authenticateToken, deleteComment);

module.exports = router;