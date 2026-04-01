const bookService = require('../services/book_services');

const getAllBooks = async (req, res) => {
  try {
    const books = await bookService.getAllBooks(req.query);
    res.status(200).json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getBookById = async (req, res) => {
  try {
    const bookId = req.params.id;
    const book = await bookService.getBookById(bookId);
    res.status(200).json(book);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

const getSellerBooks = async (req, res) => {
  try {
    // const sellerId = req.user.id; 
    const sellerId = 1;
    const books = await bookService.getSellerBooks(sellerId);
    res.status(200).json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createBook = async (req, res) => {
  try {
    // const sellerId = req.user.id;
    const sellerId = 1;

    const bookData = { ...req.body };

    if (req.file) {
      bookData.imageUrl = `/uploads/${req.file.filename}`; 
    }

    const newBook = await bookService.createBook(bookData, sellerId);
    res.status(201).json({ message: "Book created successfully", book: newBook });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateBook = async (req, res) => {
  try {
    const bookId = req.params.id;
    // const sellerId = req.user.id;
    const sellerId = 1;

    const bookData = { ...req.body };

    if (req.file) {
      bookData.imageUrl = `/uploads/${req.file.filename}`;
    }

    const updatedBook = await bookService.updateBook(bookId, bookData, sellerId);
    res.status(200).json({ message: "Book updated successfully", book: updatedBook });
  } catch (error) {
    res.status(403).json({ message: error.message });
  }
};

const deleteBook = async (req, res) => {
  try {
    const bookId = req.params.id;
    // const sellerId = req.user.id;
    const sellerId = 1; // วิชามารชั่วคราว
    
    await bookService.deleteBook(bookId, sellerId);
    res.status(200).json({ message: "Book deleted successfully" });
  } catch (error) {
    res.status(403).json({ message: error.message });
  }
};

module.exports = {
  getAllBooks,
  getBookById,
  getSellerBooks,
  createBook,
  updateBook,
  deleteBook
};