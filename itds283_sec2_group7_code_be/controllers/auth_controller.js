const register = async (req, res) => {
  // TODO: รับข้อมูลสมัครสมาชิก (email, password, firstName, lastName, phone, dob) 
  // นำ password ไป hash ด้วย bcrypt และบันทึกลงตาราง User
};

const login = async (req, res) => {
  // TODO: รับ email, password มาตรวจสอบกับ Database 
  // ถ้าถูกต้อง ให้สร้าง JWT Token ส่งกลับไปให้ Flutter
};

const googleLogin = async (req, res) => {
  // TODO: รับข้อมูลจาก Google Sign-in ฝั่งแอป
  // เช็คว่ามี User นี้หรือยัง ถ้ายังให้สร้างใหม่ แล้วคืนค่า JWT Token
};

module.exports = {
  register,
  login,
  googleLogin
};