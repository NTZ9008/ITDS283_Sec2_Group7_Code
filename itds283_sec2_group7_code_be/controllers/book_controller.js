const fs = require('fs');
const path = require('path');
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
    const sellerId = req.user.id;
    const books = await bookService.getSellerBooks(sellerId);
    res.status(200).json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createBook = async (req, res) => {
  try {
    const sellerId = req.user.id;
    const bookData = { ...req.body };

    // ✅ เช็คชื่อซ้ำ
    const existing = await bookService.findBookByTitle(bookData.title, sellerId);
    if (existing) {
      return res.status(400).json({ 
        message: `มีหนังสือชื่อ "${bookData.title}" อยู่แล้ว กรุณาใช้ชื่ออื่น` 
      });
    }

    if (req.files && req.files['image']) {
      bookData.imageUrl = `/uploads/${req.files['image'][0].filename}`;
    }
    if (req.files && req.files['pdf']) {
      bookData.pdfUrl = `/uploads/${req.files['pdf'][0].filename}`;
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
    const sellerId = req.user.id; 
    const bookData = { ...req.body };
    const oldBook = await bookService.getBookById(bookId);

    if (req.files && req.files['image']) {
      bookData.imageUrl = `/uploads/${req.files['image'][0].filename}`;
      if (oldBook.imageUrl && !oldBook.imageUrl.includes('via.placeholder.com')) {
        const filename = oldBook.imageUrl.split('/').pop(); 
        const oldImgPath = path.join(__dirname, '..', 'uploads', filename); 
        
        if (fs.existsSync(oldImgPath)) fs.unlinkSync(oldImgPath);
      }
    }

    if (req.files && req.files['pdf']) {
      bookData.pdfUrl = `/uploads/${req.files['pdf'][0].filename}`;
      
      if (oldBook.pdfUrl) {
        const filename = oldBook.pdfUrl.split('/').pop();
        const oldPdfPath = path.join(__dirname, '..', 'uploads', filename);
        
        if (fs.existsSync(oldPdfPath)) fs.unlinkSync(oldPdfPath);
      }
    }

    const updatedBook = await bookService.updateBook(bookId, bookData, sellerId);
    res.status(200).json({ message: "Book updated successfully", book: updatedBook });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteBook = async (req, res) => {
  try {
    const bookId = req.params.id;
    const sellerId = req.user.id;
    const book = await bookService.getBookById(bookId);
    await bookService.deleteBook(bookId, sellerId);

    if (book && book.imageUrl && !book.imageUrl.includes('via.placeholder.com')) {
      const filename = book.imageUrl.split('/').pop(); // ตัดเอามาแค่ชื่อไฟล์
      const imgPath = path.join(__dirname, '..', 'uploads', filename); // ประกอบร่างใหม่ให้ชัวร์
      if (fs.existsSync(imgPath)) {
        fs.unlinkSync(imgPath); 
      }
    }

    if (book && book.pdfUrl) {
      const filename = book.pdfUrl.split('/').pop();
      const pdfPath = path.join(__dirname, '..', 'uploads', filename);
      
      if (fs.existsSync(pdfPath)) {
        fs.unlinkSync(pdfPath); 
      }
    }

    res.status(200).json({ message: "Book and associated files deleted successfully" });
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