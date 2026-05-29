const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');

// Endpoint untuk pengumuman
router.post('/announcements', authMiddleware, adminController.createAnnouncement);
router.get('/announcements', adminController.getAnnouncements); // Public/Users bisa lihat

// Endpoint untuk kategori
router.post('/categories', authMiddleware, adminController.createCategory);

module.exports = router;
