const express = require('express');
const router = express.Router();
const appVersionController = require('../controllers/appVersionController');
const authMiddleware = require('../middleware/authMiddleware');

// Public route to check latest version
router.get('/version/latest', appVersionController.getLatestVersion);

// Protected route to publish new version (Super Admin only)
router.post('/version', authMiddleware, appVersionController.publishNewVersion);

module.exports = router;
