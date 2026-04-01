const express = require('express');
const router = express.Router();
const userController = require('../controllers/user_controller');
const authMiddleware = require('../middlewares/auth_middleware');

router.use(authMiddleware);

router.get('/profile', userController.getUserProfile);

router.get('/favorites', userController.getFavorites);
router.post('/favorites/toggle', userController.toggleFavorite);

router.get('/library', userController.getLibrary);
router.put('/library/:bookId/progress', userController.updateReadingProgress);

module.exports = router;