const express = require('express');
const router = express.Router();
const pool = require('../database');

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM notifications ORDER BY sent_at DESC');
    res.json({ success: true, notifications: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Function to broadcast new notification
function sendNotification(io, message) {
  io.emit('newNotification', message); // all clients
}

// Export router separately, helper separately
module.exports = router;
module.exports.sendNotification = sendNotification;
