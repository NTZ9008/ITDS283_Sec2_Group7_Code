const getUserProfile = async (req, res) => {
  // TODO: ดึงข้อมูลชื่อ-อีเมล มาโชว์ในหน้า User Screen
};

const getFavorites = async (req, res) => {
  // TODO: ดึงรายการหนังสือที่ User กดหัวใจไว้ (หน้า My Favorites)
};

const toggleFavorite = async (req, res) => {
  // TODO: สลับสถานะหัวใจ (ถ้ามีอยู่แล้วให้ลบทิ้ง ถ้าไม่มีให้เพิ่มเข้าตาราง Favorite)
};

const getLibrary = async (req, res) => {
  // TODO: ดึงรายการหนังสือทั้งหมดที่ User ซื้อสำเร็จแล้ว (หน้า Library)
};

const updateReadingProgress = async (req, res) => {
  // TODO: อัปเดตสถานะการอ่านของหนังสือเล่มนั้นๆ (เช่น หน้าปัจจุบันที่อ่านค้างไว้, หน้าที่ Bookmark, สถานะ Download)
};

module.exports = {
  getUserProfile,
  getFavorites,
  toggleFavorite,
  getLibrary,
  updateReadingProgress
};