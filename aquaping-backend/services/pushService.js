// services/pushService.js
const admin = require('firebase-admin');
const fs = require('fs');
require('dotenv').config();

const svcPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

if (!admin.apps.length) {
  if (!svcPath || !fs.existsSync(svcPath)) {
    console.warn('Firebase service account not found. Push notifications disabled.');
  } else {
    const serviceAccount = require(svcPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  }
}

// send push to a list of fcm tokens
async function sendPush(tokens = [], title = 'AquaPing Alert', body = '', data = {}) {
  if (!admin.apps.length) {
    console.warn('Firebase not initialized. Skipping push send.');
    return;
  }
  if (!tokens || tokens.length === 0) return;
  const message = {
    notification: { title, body },
    data: { ...data, severity: data.severity || '' },
    tokens
  };
  try {
    const resp = await admin.messaging().sendMulticast(message);
    return resp;
  } catch (err) {
    console.error('FCM send error', err);
    throw err;
  }
}

module.exports = {
  sendPush
};
