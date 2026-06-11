require('dotenv').config();
const { sendNewPasswordEmail } = require('./utils/emailService');

async function testEmail() {
  console.log("Menguji pengiriman email pakai:", process.env.EMAIL_USER);
  const result = await sendNewPasswordEmail('royyanialb@gmail.com', 'TestPassword123');
  console.log("Hasil:", result ? "SUKSES" : "GAGAL");
}

testEmail();
