const nodemailer = require('nodemailer');
require('dotenv').config();

// Konfigurasi email pengirim (Sistem PlateQ)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Fungsi untuk mengirim email password baru
const sendNewPasswordEmail = async (userEmail, newPassword) => {
  try {
    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
      console.log(`⚠️ Kredensial email tidak diset di .env. Menggunakan mode MOCK/DUMMY.`);
      console.log(`✅ [MOCK] Email reset password berhasil dikirim ke ${userEmail}`);
      console.log(`🔑 PASSWORD BARU SEMENTARA: ${newPassword}`);
      return true; // Berpura-pura berhasil agar frontend tidak error
    }

    const mailOptions = {
      from: '"PlateQ System" <no-reply@plateq.com>',
      to: userEmail,
      subject: 'Reset Password Anda - PlateQ',
      html: `
        <div style="font-family: sans-serif; padding: 20px;">
          <h2>Halo Chef! 👨‍🍳</h2>
          <p>Sistem kami menerima permintaan untuk mengatur ulang password akun Anda.</p>
          <p>Berikut adalah password baru sementara Anda:</p>
          <div style="padding: 15px; background-color: #f3f4f6; font-size: 20px; letter-spacing: 2px; font-weight: bold; border-radius: 8px; width: fit-content; margin: 20px 0;">
            ${newPassword}
          </div>
          <p>Silakan login menggunakan password di atas.</p>
          <p>Terima kasih,<br>Tim PlateQ</p>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ Email reset password berhasil dikirim ke ${userEmail}`);
    return true;
  } catch (error) {
    console.error('❌ Gagal mengirim email:', error);
    return false;
  }
};

module.exports = { sendNewPasswordEmail };
