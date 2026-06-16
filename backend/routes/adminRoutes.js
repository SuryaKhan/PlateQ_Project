const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');

// Endpoint untuk pengumuman
router.post('/announcements', authMiddleware, adminController.createAnnouncement);
router.get('/announcements', adminController.getAnnouncements); // Public/Users bisa lihat

// Endpoint untuk kategori
router.post('/categories', authMiddleware, adminController.createCategory);

// Endpoint untuk Stats Dashboard
router.get('/stats', authMiddleware, adminController.getStats);

// Endpoint untuk Manajemen Pengguna
router.get('/users', authMiddleware, adminController.getAllUsers);
router.delete('/users/:id', authMiddleware, adminController.deleteUser);

// Endpoint untuk Manajemen Resep
router.get('/recipes', authMiddleware, adminController.getAllRecipes);
router.delete('/recipes/:id', authMiddleware, adminController.deleteRecipe);

module.exports = router;
