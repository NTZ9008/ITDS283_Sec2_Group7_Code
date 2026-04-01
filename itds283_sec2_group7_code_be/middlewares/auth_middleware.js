const authMiddleware = (req, res, next) => {
  next();
};

module.exports = { authenticate: authMiddleware };