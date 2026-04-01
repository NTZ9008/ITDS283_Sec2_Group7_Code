const express = require("express");
const router = express.Router();
const bookController = require("../controllers/book_controller");
const {
  authenticate: authMiddleware,
} = require("../middlewares/auth_middleware");

const uploadMiddleware = require("../middlewares/upload_middleware");

router.get("/", bookController.getAllBooks);
router.get("/:id", bookController.getBookById);

router.get("/seller/my-books", authMiddleware, bookController.getSellerBooks);

router.post("/", authMiddleware, uploadMiddleware, bookController.createBook);
router.put("/:id", authMiddleware, uploadMiddleware, bookController.updateBook);

router.delete("/:id", authMiddleware, bookController.deleteBook);

module.exports = router;
