const getAllBooks = async (req, res) => {
  // TODO: ดึงรายการหนังสือทั้งหมด (ใช้โชว์หน้า Home, Search)
  // ควรรองรับการ Filter ตามหมวดหมู่ (Category) และการ Search ชื่อ
};

const getBookById = async (req, res) => {
  // TODO: ดึงข้อมูลหนังสือ 1 เล่ม แบบละเอียด (ใช้สำหรับหน้า Product Detail)
};

const getSellerBooks = async (req, res) => {
  // TODO: ดึงรายการหนังสือที่ User คนนี้เป็นคนลงขาย (ใช้สำหรับหน้า My Products)
};

const createBook = async (req, res) => {
  // TODO: รับข้อมูลหนังสือใหม่จากหน้า Add Product และบันทึกลง Database
};

const updateBook = async (req, res) => {
  // TODO: แก้ไขข้อมูลหนังสือเดิมจากหน้า Edit Product
};

const deleteBook = async (req, res) => {
  // TODO: ลบหนังสือของตัวเอง (อาจจะแค่เปลี่ยน status เป็น inactive เพื่อไม่ให้กระทบคนที่ซื้อไปแล้ว)
};

module.exports = {
  getAllBooks,
  getBookById,
  getSellerBooks,
  createBook,
  updateBook,
  deleteBook
};