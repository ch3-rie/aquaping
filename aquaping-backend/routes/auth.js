// routes/auth.js
const express = require('express');
const router = express.Router();
const pool = require('../database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// register
router.post('/register', async (req, res) => {
  const { email, password, name, contact_number, address, sms_opt_in } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Email and password required' });
  try {
    const [rows] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (rows.length) return res.status(400).json({ message: 'User already exists' });
    const hash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (email,password_hash,name,contact_number,address,sms_opt_in) VALUES (?,?,?,?,?,?)',
      [email, hash, name || null, contact_number || null, address || null, sms_opt_in ? 1 : 0]
    );
    const userId = result.insertId;
    const token = jwt.sign({ id: userId, email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    res.json({ success: true, token, user: { id: userId, email, name } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'Email and password required' });
  try {
    const [rows] = await pool.query('SELECT id,password_hash,name,contact_number,address,profile_pic,sms_opt_in,fcm_token FROM users WHERE email = ?', [email]);
    if (!rows.length) return res.status(401).json({ message: 'User not found' });
    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ message: 'Wrong password' });
    const token = jwt.sign({ id: user.id, email }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        email,
        name: user.name,
        contact_number: user.contact_number,
        address: user.address,
        profile_pic: user.profile_pic,
        sms_opt_in: !!user.sms_opt_in,
        fcm_token: user.fcm_token || null
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
