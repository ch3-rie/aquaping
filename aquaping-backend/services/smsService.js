// services/smsService.js
require('dotenv').config();
const twilioSid = process.env.TWILIO_ACCOUNT_SID;
const twilioToken = process.env.TWILIO_AUTH_TOKEN;
const twilioFrom = process.env.TWILIO_FROM;

let client = null;
if (twilioSid && twilioToken) {
  const twilio = require('twilio');
  client = twilio(twilioSid, twilioToken);
} else {
  console.warn('Twilio not configured. SMS disabled.');
}

// send sms to a list of numbers
async function sendSms(numbers = [], message = '') {
  if (!client) {
    console.warn('SMS client not configured. Skipping SMS send.');
    return;
  }
  const sends = numbers.map(n => client.messages.create({ from: twilioFrom, to: n, body: message }));
  return Promise.all(sends);
}

module.exports = {
  sendSms
};
