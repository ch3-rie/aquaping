const express = require('express');
const router = express.Router();
const db = require('../database');

router.post('/save-token', (req, res) => {
  const { user_id, token } = req.body;

  db.query(
    "UPDATE users SET fcm_token = ? WHERE id = ?",
    [token, user_id],
    (err) => {
      if (err) return res.json({ success: false, error: err });
      res.json({ success: true });
    }
  );
});

module.exports = router;
