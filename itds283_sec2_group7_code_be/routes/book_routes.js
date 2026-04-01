const express = require('express');
const router = express.Router();
const bookController = require('../controllers/book_controller');
const upload = require('../middlewares/upload_middleware');
const { authenticate: authMiddleware } = require('../middlewares/auth_middleware');

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);

router.get('/seller/my-books', authMiddleware, bookController.getSellerBooks);
router.post('/', upload.single('image'), bookController.createBook);
router.put('/:id', upload.single('image'), bookController.updateBook);
router.delete('/:id', authMiddleware, bookController.deleteBook);

module.exports = router;