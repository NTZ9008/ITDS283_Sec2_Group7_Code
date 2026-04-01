const express = require('express');
const router = express.Router();

const authRoutes = require('./auth_routes');
const bookRoutes = require('./book_routes');
const cartRoutes = require('./cart_routes');
const orderRoutes = require('./order_routes');

router.use('/auth', authRoutes);
router.use('/books', bookRoutes);
router.use('/cart', cartRoutes);
router.use('/orders', orderRoutes);

router.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: '67-E Book API is running!' });
});

module.exports = router;