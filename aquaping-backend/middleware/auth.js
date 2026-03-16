const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pool = require('../database');
require('dotenv').config();
const JWT_SECRET = process.env.JWT_SECRET;

// Register route
router.post('/register', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ success: false, message: 'Email and password required' });

  try {
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length) return res.json({ success: false, message: 'User already exists' });

    await pool.query('INSERT INTO users (email, password) VALUES (?, ?)', [email, password]);
    res.json({ success: true, message: 'User registered' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Login route
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [users] = await pool.query('SELECT id, email FROM users WHERE email = ? AND password = ?', [email, password]);
    if (!users.length) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ id: users[0].id, email: users[0].email }, JWT_SECRET);
    res.json({ success: true, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
