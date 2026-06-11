const express = require('express');
const router = express.Router();
const { register, login, forgotPassword, changePassword } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/change-password', changePassword);

module.exports = router;