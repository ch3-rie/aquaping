const express = require('express');
const router = express.Router();
const pool = require('../database');

// Register device
router.post('/register', async (req, res) => {
  const { device_id, name, region } = req.body;
  if (!device_id) return res.status(400).json({ success: false, message: 'device_id required' });

  try {
    const [existing] = await pool.query('SELECT id FROM devices WHERE device_id = ?', [device_id]);
    if (existing.length) return res.json({ success: true, message: 'Device exists' });

    await pool.query('INSERT INTO devices (device_id, name, region) VALUES (?,?,?)', [device_id, name || null, region || null]);
    res.json({ success: true, message: 'Device registered' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// List devices
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM devices ORDER BY created_at DESC');
    res.json({ success: true, devices: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
