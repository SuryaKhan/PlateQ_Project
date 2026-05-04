const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware'); // Supaya cuma yang punya token bisa akses

// Update profil (menggunakan PUT karena kita merubah data yang sudah ada)
router.put('/update-profile', authMiddleware, userController.updateProfile);

module.exports = router;