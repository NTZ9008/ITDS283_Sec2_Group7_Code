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

exports.addToCart = async (userId, bookId) => {
  let cart = await prisma.cart.findUnique({ where: { userId: parseInt(userId) } });
  if (!cart) {
    cart = await prisma.cart.create({ data: { userId: parseInt(userId) } });
  }

  const alreadyOwned = await prisma.libraryItem.findUnique({
    where: {
      userId_bookId: { userId: parseInt(userId), bookId: parseInt(bookId) }
    }
  });
  if (alreadyOwned) {
    throw new Error("You already own this E-Book.");
  }

  const existingItem = await prisma.cartItem.findFirst({
    where: { cartId: cart.id, bookId: parseInt(bookId) }
  });
  if (existingItem) {
    throw new Error("This E-Book is already in your cart.");
  }

  return await prisma.cartItem.create({
    data: {
      cartId: cart.id,
      bookId: parseInt(bookId),
      quantity: 1
    }
  });
};

exports.updateCartItem = async (cartItemId, quantity) => {
  if (parseInt(quantity) <= 0) {
    return await prisma.cartItem.delete({ where: { id: parseInt(cartItemId) } });
  }

  if (parseInt(quantity) > 1) {
    throw new Error("E-Books can only have a maximum quantity of 1.");
  }
  
  return await prisma.cartItem.update({
    where: { id: parseInt(cartItemId) },
    data: { quantity: 1 }
  });
};

exports.removeFromCart = async (cartItemId) => {
  return await prisma.cartItem.delete({
    where: { id: parseInt(cartItemId) }
  });
};