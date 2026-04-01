const prisma = require('../configs/db');

// GET /api/users/profile
const getUserProfile = async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        phone: true,
        dob: true,
        role: true,
        createdAt: true,
      },
    });

    if (!user) return res.status(404).json({ message: 'User not found' });

    return res.status(200).json({ user });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// GET /api/users/favorites
const getFavorites = async (req, res) => {
  try {
    const favorites = await prisma.favorite.findMany({
      where: { userId: req.user.id },
      include: {
        book: {
          select: {
            id: true,
            title: true,
            author: true,
            category: true,
            description: true,
            price: true,
            imageUrl: true,
          },
        },
      },
    });

    const books = favorites.map((f) => f.book);

    return res.status(200).json({ favorites: books });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// POST /api/users/favorites/toggle
// Body: { bookId }
const toggleFavorite = async (req, res) => {
  try {
    const { bookId } = req.body;
    const userId = req.user.id;

    if (!bookId) {
      return res.status(400).json({ message: 'bookId is required' });
    }

    const existing = await prisma.favorite.findUnique({
      where: { userId_bookId: { userId, bookId } },
    });

    if (existing) {
      // มีอยู่แล้ว → ลบออก
      await prisma.favorite.delete({
        where: { userId_bookId: { userId, bookId } },
      });
      return res.status(200).json({ message: 'Removed from favorites', isFavorite: false });
    } else {
      // ยังไม่มี → เพิ่มเข้า
      await prisma.favorite.create({
        data: { userId, bookId },
      });
      return res.status(201).json({ message: 'Added to favorites', isFavorite: true });
    }
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// GET /api/users/library
const getLibrary = async (req, res) => {
  try {
    const library = await prisma.libraryItem.findMany({
      where: { userId: req.user.id },
      include: {
        book: {
          select: {
            id: true,
            title: true,
            author: true,
            category: true,
            description: true,
            price: true,
            imageUrl: true,
          },
        },
      },
    });

    const result = library.map((item) => ({
      ...item.book,
      isDownloaded: item.isDownloaded,
      currentPage: item.currentPage,
      bookmarkedPages: item.bookmarkedPages,
    }));

    return res.status(200).json({ library: result });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// PUT /api/users/library/:bookId/progress
// Body: { currentPage, bookmarkedPages, isDownloaded }
const updateReadingProgress = async (req, res) => {
  try {
    const bookId = parseInt(req.params.bookId);
    const userId = req.user.id;
    const { currentPage, bookmarkedPages, isDownloaded } = req.body;

    const existing = await prisma.libraryItem.findUnique({
      where: { userId_bookId: { userId, bookId } },
    });

    if (!existing) {
      return res.status(404).json({ message: 'Book not found in library' });
    }

    const updated = await prisma.libraryItem.update({
      where: { userId_bookId: { userId, bookId } },
      data: {
        ...(currentPage !== undefined && { currentPage }),
        ...(bookmarkedPages !== undefined && { bookmarkedPages }),
        ...(isDownloaded !== undefined && { isDownloaded }),
      },
    });

    return res.status(200).json({ message: 'Progress updated', item: updated });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getUserProfile,
  getFavorites,
  toggleFavorite,
  getLibrary,
  updateReadingProgress,
};