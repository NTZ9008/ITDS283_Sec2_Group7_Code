const checkPromoCode = async (req, res) => {
  // TODO: รับ Promo Code มาเช็คกับตาราง PromoCode ว่ามีจริงไหม และคืนค่า % ส่วนลดกลับไป
};

const checkout = async (req, res) => {
  // TODO: ระบบสำคัญ! (Transaction)
  // 1. รับข้อมูลที่อยู่จัดส่ง, ยอดรวม, สินค้าที่เลือก
  // 2. สร้าง Order และ OrderItem
  // 3. เอาหนังสือที่สั่งซื้อ สำเนาก๊อปปี้ไปใส่ในตาราง LibraryItem ของ User
  // 4. ลบสินค้าที่จ่ายเงินแล้ว ออกจากตาราง CartItem
};

const getOrderHistory = async (req, res) => {
  // TODO: ดึงประวัติการสั่งซื้อ (เผื่อทำหน้าประวัติการสั่งซื้อในอนาคต)
};

module.exports = {
  checkPromoCode,
  checkout,
  getOrderHistory
};