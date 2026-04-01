const authService = require('../services/auth_services');

// POST /api/auth/register
const register = async (req, res) => {
  try {
    const { email, password, firstName, lastName, phone, dob } = req.body;

    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({
        message: 'email, password, firstName and lastName are required',
      });
    }

    const user = await authService.register({
      email, password, firstName, lastName, phone, dob,
    });

    return res.status(201).json({ message: 'Register successful', user });
  } catch (error) {
    const status = error.message.includes('already') ? 409 : 500;
    return res.status(status).json({ message: error.message });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const result = await authService.login({ email, password });

    return res.status(200).json({
      message: 'Login successful',
      token: result.token,
      user: result.user,
    });
  } catch (error) {
    const status =
      error.message.includes('Invalid') || error.message.includes('Google') ? 401 : 500;
    return res.status(status).json({ message: error.message });
  }
};

// POST /api/auth/google-login
const googleLogin = async (req, res) => {
  try {
    const { googleId, email, firstName, lastName } = req.body;

    if (!googleId || !email) {
      return res.status(400).json({ message: 'googleId and email are required' });
    }

    const result = await authService.googleLogin({
      googleId, email, firstName, lastName,
    });

    return res.status(200).json({
      message: 'Google login successful',
      token: result.token,
      user: result.user,
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// GET /api/auth/me  (ต้องผ่าน authenticate middleware)
const getMe = async (req, res) => {
  try {
    const user = await authService.getProfile(req.user.id);
    return res.status(200).json({ user });
  } catch (error) {
    return res.status(404).json({ message: error.message });
  }
};

module.exports = { register, login, googleLogin, getMe };