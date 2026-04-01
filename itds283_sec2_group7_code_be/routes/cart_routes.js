const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart_controller');
const authMiddleware = require('../middlewares/auth_middleware');

router.use(authMiddleware);

router.get('/', cartController.getCart);
router.post('/add', cartController.addToCart);
router.put('/update', cartController.updateCartItem);
router.delete('/remove/:id', cartController.removeFromCart);

module.exports = router;