const express = require('express');
const router = express.Router();
const pool = require('../database');

// Flood zones
router.get('/zones', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, name, severity, polygon_geojson FROM flood_zones ORDER BY id');
    res.json({ success: true, zones: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// Evacuation centers
router.get('/evac_centers', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, name, latitude, longitude, address FROM evacuation_centers ORDER BY name');
    res.json({ success: true, centers: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

module.exports = router;
