const getCart = async (req, res) => {
  // TODO: ดึงรายการสินค้าทั้งหมดในตะกร้าของ User ที่ล็อกอินอยู่
};

const addToCart = async (req, res) => {
  // TODO: รับ bookId และ quantity เพิ่มลงในตาราง CartItem 
  // (ถ้ามีหนังสือเล่มนี้ในตะกร้าอยู่แล้ว ให้บวกจำนวนเพิ่ม)
};

const updateCartItem = async (req, res) => {
  // TODO: อัปเดตจำนวนสินค้า (+ หรือ -) ในตะกร้า
};

const removeFromCart = async (req, res) => {
  // TODO: ลบหนังสือออกจากตะกร้า
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart
};