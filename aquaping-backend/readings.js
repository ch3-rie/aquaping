// readings.js
const express = require('express');
const router = express.Router();
const pool = require('../database');

// Add reading
router.post('/add', async (req, res) => {
  const { device_id, water_level } = req.body;

  if (!device_id || water_level == null)
    return res.status(400).json({ success: false, message: 'Missing parameters' });

  // === MATCH ARDUINO SEVERITY LOGIC ===
  let severity = "none";

  if (water_level < 100) severity = "none";
  else if (water_level < 120) severity = "green";
  else if (water_level < 130) severity = "yellow";
  else if (water_level < 150) severity = "orange";
  else severity = "red";

  try {
    await pool.query(
      'INSERT INTO readings (device_id, water_level, severity) VALUES (?, ?, ?)',
      [device_id, water_level, severity]
    );

    // emit socket
    const io = req.app.get('io');
    io.emit('reading', { device_id, water_level, severity });

    res.json({ success: true, severity });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});


// Get recent readings
router.get('/recent', async (req, res) => {
  const { device_id, limit = 20 } = req.query;

  if (!device_id)
    return res.status(400).json({ success: false, message: 'Missing device_id' });

  try {
    const [rows] = await pool.query(
      'SELECT * FROM readings WHERE device_id = ? ORDER BY created_at DESC LIMIT ?',
      [device_id, parseInt(limit)]
    );

    res.json({ success: true, readings: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
