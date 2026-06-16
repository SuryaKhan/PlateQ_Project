require('dotenv').config();
const bcrypt = require('bcrypt');
const prisma = require('./db');

async function run() {
  const p = await bcrypt.hash('superadmin123', 10);
  await prisma.user.update({
    where: { email: 'superadmin@plateq.com' },
    data: { password: p }
  });
  console.log('Password reset to superadmin123');
}

run().finally(() => prisma.$disconnect());
