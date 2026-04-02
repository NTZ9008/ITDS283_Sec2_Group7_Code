const express = require("express");
const router = express.Router();
const bookController = require("../controllers/book_controller");
const {
  authenticate: authMiddleware,
  authorize
} = require("../middlewares/auth_middleware");

const uploadMiddleware = require("../middlewares/upload_middleware");

router.get("/", bookController.getAllBooks);
router.get("/:id", bookController.getBookById);

router.get("/seller/my-books", authMiddleware, authorize('SELLER'), bookController.getSellerBooks);

router.post("/", authMiddleware, authorize('SELLER'), uploadMiddleware, bookController.createBook);
router.put("/:id", authMiddleware, authorize('SELLER'), uploadMiddleware, bookController.updateBook);

router.delete("/:id", authMiddleware, authorize('SELLER'), bookController.deleteBook);

module.exports = router;
