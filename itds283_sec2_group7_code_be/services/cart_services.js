const prisma = require('../configs/db');

exports.getCartByUserId = async (userId) => {
  let cart = await prisma.cart.findUnique({
    where: { userId: parseInt(userId) },
    include: {
      items: {
        include: { book: true },
        orderBy: { id: 'asc' }
      }
    }
  });

  if (!cart) {
    cart = await prisma.cart.create({
      data: { userId: parseInt(userId) },
      include: { items: { include: { book: true } } }
    });
  }
  return cart;
};

exports.addToCart = async (userId, bookId, quantity = 1) => {
  let cart = await prisma.cart.findUnique({ where: { userId: parseInt(userId) } });
  if (!cart) {
    cart = await prisma.cart.create({ data: { userId: parseInt(userId) } });
  }

  const existingItem = await prisma.cartItem.findFirst({
    where: { cartId: cart.id, bookId: parseInt(bookId) }
  });

  if (existingItem) {
    return await prisma.cartItem.update({
      where: { id: existingItem.id },
      data: { quantity: existingItem.quantity + parseInt(quantity) }
    });
  } else {
    return await prisma.cartItem.create({
      data: {
        cartId: cart.id,
        bookId: parseInt(bookId),
        quantity: parseInt(quantity)
      }
    });
  }
};

exports.updateCartItem = async (cartItemId, quantity) => {
  if (parseInt(quantity) <= 0) {
    return await prisma.cartItem.delete({ where: { id: parseInt(cartItemId) } });
  }
  
  return await prisma.cartItem.update({
    where: { id: parseInt(cartItemId) },
    data: { quantity: parseInt(quantity) }
  });
};

exports.removeFromCart = async (cartItemId) => {
  return await prisma.cartItem.delete({
    where: { id: parseInt(cartItemId) }
  });
};