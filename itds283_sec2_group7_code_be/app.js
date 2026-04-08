const express = require('express');
const cors = require('cors');
const path = require('path');
const routes = require('./routes');
const rateLimit = require('express-rate-limit');

const app = express();

app.set('trust proxy', 1);
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: 'error',
    message: 'Too many requests from this IP, please try again after 15 minutes'
  }
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api', apiLimiter, routes);

app.use((err, req, res, next) => {
  console.error(err.stack);

  if (err.name === 'MulterError') {
    return res.status(400).json({ status: 'error', message: err.message });
  }

  res.status(500).json({
    status: 'error',
    message: err.message || 'Internal Server Error',
  });
});

module.exports = app;