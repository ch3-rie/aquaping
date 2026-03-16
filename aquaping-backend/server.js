// server.js
require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Server } = require('socket.io');

const authRoutes = require('./routes/auth');
const deviceRoutes = require('./routes/devices');
const readingRoutes = require('./routes/readings');
const mapRoutes = require('./routes/map');
const notifRoutes = require('./routes/notifications');

const app = express(); // <-- app must be declared first
const server = http.createServer(app);

const io = new Server(server, {
    cors: { origin: '*',
    methods: ['GET', 'POST']
  }
});

// provide io to routes
app.set('io', io);

app.use(cors());
app.use(bodyParser.json());

// routes
app.use('/api/auth', authRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/readings', readingRoutes);
app.use('/api/map', mapRoutes);
app.use('/api/notifications', notifRoutes); // <-- after app exists

io.on('connection', (socket) => {
  console.log('client connected', socket.id);
  socket.on('subscribe:device', (deviceId) => {
    socket.join(`device:${deviceId}`);
  });
  socket.on('disconnect', () => {});
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => 
  console.log(`AquaPing API running on ${PORT}`)
);
