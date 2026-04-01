const authMiddleware = (req, res, next) => {
  next();
};

// ── ตรวจสอบ Role ──
// ใช้งาน: authorize('ADMIN') หรือ authorize('ADMIN', 'SELLER')
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden: insufficient permissions' });
    }
    next();
  };
};

module.exports = { authenticate, authorize };
