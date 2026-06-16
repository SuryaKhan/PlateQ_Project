const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Update profil teks (json)
router.put('/update-profile', authMiddleware, userController.updateProfile);

// Upload Foto Profil
router.put('/upload-profile-image', authMiddleware, upload.single('profileImage'), userController.uploadProfileImage);

// Get profil detail
router.get('/profile', authMiddleware, userController.getProfile);

// Get profil publik user lain
router.get('/public/:id', authMiddleware, userController.getPublicProfile);

// Search Users
router.get('/search', userController.searchUsers);

// Ubah Password
router.put('/change-password', authMiddleware, userController.changePassword);

module.exports = router;