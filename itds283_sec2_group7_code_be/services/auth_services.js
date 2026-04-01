const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

const SALT_ROUNDS = 10;

const generateToken = (user) =>
  jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

// ── Register ──
const register = async ({ email, password, firstName, lastName, phone, dob }) => {
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) throw new Error('Email already in use');

  const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

  const user = await prisma.user.create({
    data: {
      email,
      password: hashedPassword,
      firstName,
      lastName,
      phone,
      dob: dob ?? null,
    },
    select: {
      id: true, email: true,
      firstName: true, lastName: true,
      phone: true, dob: true,
      role: true, createdAt: true,
    },
  });

  return user;
};

// ── Login ──
const login = async ({ email, password }) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error('Invalid email or password');

  // กรณี user สมัครผ่าน Google ไม่มี password
  if (!user.password) throw new Error('This account uses Google Sign-in');

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid email or password');

  const token = generateToken(user);

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
    },
  };
};

// ── Google Login ──
// Flutter ส่ง googleId + email + firstName + lastName มาให้
const googleLogin = async ({ googleId, email, firstName, lastName }) => {
  let user = await prisma.user.findUnique({ where: { email } });

  if (!user) {
    // สร้าง user ใหม่
    user = await prisma.user.create({
      data: { email, firstName, lastName, googleId, password: '' },
    });
  } else if (!user.googleId) {
    // มี account อยู่แล้วแต่ยังไม่ได้ link Google
    user = await prisma.user.update({
      where: { email },
      data: { googleId },
    });
  }

  const token = generateToken(user);

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
    },
  };
};

// ── Get profile ──
const getProfile = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true, email: true,
      firstName: true, lastName: true,
      phone: true, dob: true,
      role: true, createdAt: true,
    },
  });
  if (!user) throw new Error('User not found');
  return user;
};

module.exports = { register, login, googleLogin, getProfile };