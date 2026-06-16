const express = require('express');
const router = express.Router();
const socialController = require('../controllers/socialController');
const authenticateToken = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

// Multer Config for Cooksnaps
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'cooksnap-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// Follow & Unfollow
router.post('/follow/:id', authenticateToken, socialController.toggleFollow);

// Cooksnaps
router.post('/recipes/:recipeId/cooksnaps', authenticateToken, upload.single('image'), socialController.uploadCooksnap);

// Collections
router.post('/collections', authenticateToken, socialController.createCollection);
router.get('/collections', authenticateToken, socialController.getCollections);
router.post('/collections/:collectionId/recipes/:recipeId', authenticateToken, socialController.saveRecipeToCollection);

// Notifications
router.get('/notifications', authenticateToken, socialController.getNotifications);
router.put('/notifications/read', authenticateToken, socialController.markNotificationsAsRead);

// Feed
router.get('/feed', authenticateToken, socialController.getFeed);

module.exports = router;
