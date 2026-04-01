const prisma = require('../configs/db');

exports.checkPromoCode = async (code) => {
  const promo = await prisma.promoCode.findUnique({ where: { code } });
  if (!promo || !promo.isActive) throw new Error("Invalid or expired promo code");
  return promo;
};

exports.checkout = async (userId, data) => {
  const { promoCode, paymentMethod, fullName, phone, province, city, address, postalCode } = data;

  return await prisma.$transaction(async (tx) => {

    const cart = await tx.cart.findUnique({
      where: { userId: parseInt(userId) },
      include: { items: { include: { book: true } } }
    });
    if (!cart || cart.items.length === 0) throw new Error("Your cart is empty");

    let subTotal = cart.items.reduce((sum, item) => sum + item.book.price, 0);
    let discountAmount = 0;

    if (promoCode) {
      const promo = await tx.promoCode.findUnique({ where: { code: promoCode } });
      if (promo && promo.isActive) {
        discountAmount = subTotal * (promo.discountPercent / 100);
      }
    }
    const totalAmount = subTotal - discountAmount;

    const order = await tx.order.create({
      data: {
        userId: parseInt(userId),
        totalAmount: totalAmount,
        discount: discountAmount,
        status: "COMPLETED",
        fullName: fullName || "E-Book Reader", 
        phone: phone || "-",
        province: province || "-",
        city: city || "-",
        address: address || "-",
        postalCode: postalCode || "-",
        paymentMethod: paymentMethod || "QR",
        items: {
          create: cart.items.map(item => ({
            bookId: item.bookId,
            quantity: 1,
            price: item.book.price
          }))
        }
      }
    });

    for (const item of cart.items) {
      const existing = await tx.libraryItem.findUnique({
        where: { userId_bookId: { userId: parseInt(userId), bookId: item.bookId } }
      });
      
      if (!existing) {
        await tx.libraryItem.create({
          data: { userId: parseInt(userId), bookId: item.bookId }
        });
      }
    }

    await tx.cartItem.deleteMany({ where: { cartId: cart.id } });

    return order;
  });
};

exports.getOrderHistory = async (userId) => {
  return await prisma.order.findMany({
    where: { userId: parseInt(userId) },
    include: { items: { include: { book: true } } },
    orderBy: { createdAt: 'desc' }
  });
};