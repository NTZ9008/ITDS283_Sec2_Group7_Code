const orderService = require('../services/order_services');
const generatePayload = require('promptpay-qr');
const prisma = require('../configs/db');

const checkPromoCode = async (req, res) => {
  try {
    const { code } = req.body;
    const promo = await orderService.checkPromoCode(code);
    res.status(200).json({ message: "Promo code applied", discountPercent: promo.discountPercent });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const checkout = async (req, res) => {
  try {
    const userId = req.user.id; 

    const order = await orderService.checkout(userId, req.body);
    res.status(201).json({ message: "Checkout successful! Books added to your library.", order });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getOrderHistory = async (req, res) => {
  try {
    const userId = req.user.id;

    const orders = await orderService.getOrderHistory(userId);

    if (!orders || orders.length === 0) {
      return res.status(200).json({ 
        message: "You have no order history.", 
        orders: []
      });
    }

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getPaymentQR = async (req, res) => {
  try {
    const userId = req.user.id; 

    const cart = await prisma.cart.findUnique({
      where: { userId: parseInt(userId) },
      include: { items: { include: { book: true } } }
    });

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: "Your cart is empty" });
    }

    let totalAmount = cart.items.reduce((sum, item) => sum + item.book.price, 0);

    const promptPayID = "0826313749";

    const payload = generatePayload(promptPayID, { amount: totalAmount });

    res.status(200).json({ 
      message: "QR Payload generated successfully",
      totalAmount: totalAmount,
      qrPayload: payload 
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  checkPromoCode,
  checkout,
  getOrderHistory,
  getPaymentQR
};