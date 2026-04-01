const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order_controller');
const { authenticate } = require('../middlewares/auth_middleware');

router.use(authenticate);

router.post('/promo', orderController.checkPromoCode);
router.post('/checkout', orderController.checkout);
router.get('/history', orderController.getOrderHistory);
router.get('/qr-payment', orderController.getPaymentQR);

module.exports = router;