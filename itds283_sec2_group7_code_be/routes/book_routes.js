const express = require('express');
const router = express.Router();
const bookController = require('../controllers/book_controller');
const upload = require('../middlewares/upload_middleware');
const { authenticate: authMiddleware } = require('../middlewares/auth_middleware');

// 🟢 ตั้งค่าการรับไฟล์แบบหลายฟิลด์ ( image และ pdf )
const uploadFields = upload.fields([
  { name: 'image', maxCount: 1 }, // รับรูปปก 1 ไฟล์
  { name: 'pdf', maxCount: 1 }    // รับไฟล์เนื้อหา PDF 1 ไฟล์
]);

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);

router.get('/seller/my-books', authMiddleware, bookController.getSellerBooks);

router.post('/', authMiddleware, uploadFields, bookController.createBook);
router.put('/:id', authMiddleware, uploadFields, bookController.updateBook);

router.delete('/:id', authMiddleware, bookController.deleteBook);

module.exports = router;