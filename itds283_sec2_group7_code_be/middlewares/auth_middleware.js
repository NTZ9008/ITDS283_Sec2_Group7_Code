const authMiddleware = (req, res, next) => {
  next();
};

module.exports = { authenticate: authMiddleware }; // ✅ export เป็น object