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
    const sellerId = 1; // 🟢 วิชามาร (แก้กลับเป็น req.user.id ทีหลัง)
    const books = await bookService.getSellerBooks(sellerId);
    res.status(200).json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createBook = async (req, res) => {
  try {
    const sellerId = 1;
    const bookData = { ...req.body };
    
    // 🟢 เช็คว่ามีรูปปกส่งมาไหม
    if (req.files && req.files['image']) {
      bookData.imageUrl = `/uploads/${req.files['image'][0].filename}`; 
    }
    // 🟢 เช็คว่ามีไฟล์ PDF ส่งมาไหม
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
    const sellerId = 1; // 🟢 วิชามาร 
    const bookData = { ...req.body };
    
    // 🟢 ถ้ามีการอัปรูปปกใหม่
    if (req.files && req.files['image']) {
      bookData.imageUrl = `/uploads/${req.files['image'][0].filename}`;
    }
    // 🟢 ถ้ามีการอัปไฟล์ PDF ใหม่
    if (req.files && req.files['pdf']) {
      bookData.pdfUrl = `/uploads/${req.files['pdf'][0].filename}`;
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
    const sellerId = 1; // 🟢 วิชามาร 
    
    // ดึงข้อมูลออกมาก่อนเพื่อเอาที่อยู่ไฟล์
    const book = await bookService.getBookById(bookId);
    
    // ลบใน Database
    await bookService.deleteBook(bookId, sellerId);

    // 🟢 ลบไฟล์รูปปกทิ้ง
    if (book && book.imageUrl) {
      const imgPath = path.join(__dirname, '..', book.imageUrl);
      if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath); 
    }
    
    // 🟢 ลบไฟล์ PDF ทิ้งด้วย
    if (book && book.pdfUrl) {
      const pdfPath = path.join(__dirname, '..', book.pdfUrl);
      if (fs.existsSync(pdfPath)) fs.unlinkSync(pdfPath); 
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