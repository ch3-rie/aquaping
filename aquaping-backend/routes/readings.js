// readings.js
const express = require('express');
const router = express.Router();
const pool = require('../database');

// Generate message
function makeSeverityMessage(severity, lastSeverity) {
  if (severity === "green") return "Water rising slightly (GREEN). Stay alert.";
  if (severity === "yellow") return "Moderate water detected (YELLOW). Prepare accordingly.";
  if (severity === "orange") return "High water level (ORANGE). Possible flood risk.";
  if (severity === "red") return "CRITICAL — Water overflowing (RED). Take action now!";
  if (severity === "none" && lastSeverity !== "none") return "Water level returned to normal.";
  return null;
}

// Add reading
router.post('/add', async (req, res) => {
  const { device_id, water_level } = req.body;

  if (!device_id || water_level == null)
    return res.status(400).json({ success: false, message: 'Missing parameters' });

  // Severity logic matching Arduino
  let severity = "none";
  if (water_level < 5) severity = "none";
  else if (water_level <= 10) severity = "green";
  else if (water_level <= 15) severity = "yellow";
  else if (water_level <= 20) severity = "orange";
  else severity = "red";

  try {
    // Get last severity
    const [prev] = await pool.query(
      "SELECT severity FROM readings WHERE device_id = ? ORDER BY created_at DESC LIMIT 1",
      [device_id]
    );
    const lastSeverity = prev.length ? prev[0].severity : null;

    // Insert new reading
    await pool.query(
      'INSERT INTO readings (device_id, water_level, severity) VALUES (?, ?, ?)',
      [device_id, water_level, severity]
    );

    const io = req.app.get('io');

    // ONLY trigger when severity changes
    if (lastSeverity !== severity) {
      const msg = makeSeverityMessage(severity, lastSeverity);

      // Emit to app
      io.emit('severity_change', {
        device_id,
        water_level,
        severity,
        message: msg,
        lastSeverity
      });

      // Dashboard update
      io.emit('dashboard_update', {
        device_id,
        water_level,
        severity,
        created_at: new Date(),
        message: msg
      });

      // Save notification to DB
      await pool.query(
        "INSERT INTO notifications (device_id, severity, message) VALUES (?, ?, ?)",
        [device_id, severity, msg]
      );
    }

    res.json({ success: true, severity });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Get recent severity-change readings
router.get('/recent/:deviceId', async (req, res) => {
  const { deviceId } = req.params;

  try {
    const [rows] = await pool.query(
      `SELECT id, device_id, water_level, severity, created_at
       FROM readings
       WHERE device_id = ?
         AND created_at >= NOW() - INTERVAL 1 DAY
       ORDER BY created_at ASC`,
      [deviceId]
    );

    // Keep only entries where severity changed
    const filtered = [];
    let last = null;

    for (const r of rows) {
      if (r.severity !== last) {
        filtered.push(r);
        last = r.severity;
      }
    }

    res.json({ readings: filtered.reverse() });

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: 'DB error' });
  }
});

module.exports = router;
