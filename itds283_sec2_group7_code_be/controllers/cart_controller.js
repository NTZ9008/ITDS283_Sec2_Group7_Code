const cartService = require('../services/cart_services');

const getCart = async (req, res) => {
  try {
    // const userId = req.user.id; 
    const userId = 1;

    const cart = await cartService.getCartByUserId(userId);
    res.status(200).json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addToCart = async (req, res) => {
  try {
    // const userId = req.user.id;
    const userId = 1; 
    const { bookId, quantity } = req.body;

    const item = await cartService.addToCart(userId, bookId, quantity || 1);
    res.status(201).json({ message: "Added to cart successfully", item });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateCartItem = async (req, res) => {
  try {
    const { cartItemId, quantity } = req.body; 
    const updatedItem = await cartService.updateCartItem(cartItemId, quantity);
    res.status(200).json({ message: "Cart item updated", item: updatedItem });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const removeFromCart = async (req, res) => {
  try {
    const cartItemId = req.params.id;
    await cartService.removeFromCart(cartItemId);
    res.status(200).json({ message: "Item removed from cart" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart
};