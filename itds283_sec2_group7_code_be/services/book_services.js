const prisma = require('../configs/db');

exports.getAllBooks = async (query) => {
  const { category, search } = query;

  let whereClause = {};
  if (category) {
    whereClause.category = category;
  }
  if (search) {
    whereClause.title = {
      contains: search,
      mode: 'insensitive'
    };
  }

  return await prisma.book.findMany({
    where: whereClause,
    orderBy: { createdAt: 'desc' },
  });
};

exports.getBookById = async (id) => {
  const book = await prisma.book.findUnique({
    where: { id: parseInt(id) },
    include: { seller: { select: { firstName: true, lastName: true } } }
  });
  if (!book) throw new Error("Book not found");
  return book;
};

exports.getSellerBooks = async (sellerId) => {
  return await prisma.book.findMany({
    where: { sellerId: parseInt(sellerId) },
    orderBy: { createdAt: 'desc' },
  });
};

exports.createBook = async (data, sellerId) => {
  return await prisma.book.create({
    data: {
      title: data.title,
      author: data.author,
      category: data.category,
      description: data.description,
      price: parseFloat(data.price),
      imageUrl: data.imageUrl || 'https://via.placeholder.com/150',
      pdfUrl: data.pdfUrl,
      sellerId: parseInt(sellerId),
    },
  });
};

exports.updateBook = async (id, data, sellerId) => {
  const existingBook = await prisma.book.findUnique({ where: { id: parseInt(id) } });
  if (!existingBook) throw new Error("Book not found");
  if (existingBook.sellerId !== parseInt(sellerId)) throw new Error("Unauthorized to edit this book");

  return await prisma.book.update({
    where: { id: parseInt(id) },
    data: {
      title: data.title,
      author: data.author,
      category: data.category,
      description: data.description,
      price: parseFloat(data.price),
      imageUrl: data.imageUrl,
      pdfUrl: data.pdfUrl,
    },
  });
};

exports.deleteBook = async (id, sellerId) => {
  const existingBook = await prisma.book.findUnique({ where: { id: parseInt(id) } });
  if (!existingBook) throw new Error("Book not found");
  if (existingBook.sellerId !== parseInt(sellerId)) throw new Error("Unauthorized to delete this book");

  return await prisma.book.delete({
    where: { id: parseInt(id) },
  });
};