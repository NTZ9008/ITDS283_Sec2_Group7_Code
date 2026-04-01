const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth_controller');
const { authenticate } = require('../middlewares/auth_middleware');

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/google-login', authController.googleLogin);

// Protected route
router.get('/me', authenticate, authController.getMe);

module.exports = router;