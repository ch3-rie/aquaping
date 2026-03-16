const admin = require("firebase-admin");
const db = require("../database");

module.exports.sendAlert = (level, message) => {
  db.query("SELECT fcm_token FROM users WHERE fcm_token IS NOT NULL",
    (err, rows) => {
      if (err) return;

      rows.forEach(row => {
        admin.messaging().send({
          token: row.fcm_token,
          notification: {
            title: `AquaPing Alert: ${level.toUpperCase()}`,
            body: message
          },
          data: { level }
        });
      });
    }
  );
};
