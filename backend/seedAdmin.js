require('dotenv').config();
const prisma = require('./db');
const bcrypt = require('bcrypt');

async function main() {
  try {
    const hashedPassword = await bcrypt.hash('admin123', 10);

    // 1. Buat Akun Superadmin
    const superadmin = await prisma.user.upsert({
      where: { username: 'superadmin' },
      update: {},
      create: {
        username: 'superadmin',
        email: 'superadmin@plateq.com',
        name: 'Super Administrator',
        password: hashedPassword,
        role: 'SUPERADMIN'
      }
    });

    // 2. Buat Akun Admin Biasa
    const admin = await prisma.user.upsert({
      where: { username: 'admin' },
      update: {},
      create: {
        username: 'admin',
        email: 'admin@plateq.com',
        name: 'Administrator',
        password: hashedPassword,
        role: 'ADMIN'
      }
    });

    console.log("✅ Berhasil membuat akun default:");
    console.log("🦸‍♂️ Superadmin -> Username: superadmin | Password: admin123");
    console.log("👮‍♂️ Admin -> Username: admin | Password: admin123");
  } catch (error) {
    console.error("❌ Gagal membuat akun:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
