const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart_controller');
const { authenticate } = require('../middlewares/auth_middleware');

router.use(authenticate);

router.get('/', cartController.getCart);
router.post('/add', cartController.addToCart);
router.delete('/remove/:id', cartController.removeFromCart);

module.exports = router;