const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order_controller');
const authMiddleware = require('../middlewares/auth_middleware');

router.use(authMiddleware);

router.post('/promo', orderController.checkPromoCode);
router.post('/checkout', orderController.checkout);
router.get('/history', orderController.getOrderHistory);

module.exports = router;