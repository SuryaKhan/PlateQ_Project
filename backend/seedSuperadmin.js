require('dotenv').config();
const prisma = require('./db');
const bcrypt = require('bcrypt');

async function main() {
  const superadminEmail = "superadmin@plateq.com";
  const superadminUsername = "superadmin";
  const password = await bcrypt.hash("superadmin123", 10);

  // Check if exists
  const existing = await prisma.user.findUnique({ where: { email: superadminEmail } });

  if (existing) {
    await prisma.user.update({
      where: { email: superadminEmail },
      data: { role: 'SUPERADMIN', name: 'Super Admin Chef' }
    });
    console.log("Superadmin account updated!");
  } else {
    await prisma.user.create({
      data: {
        email: superadminEmail,
        username: superadminUsername,
        password: password,
        name: 'Super Admin Chef',
        bio: 'The creator and overlord of PlateQ.',
        role: 'SUPERADMIN'
      }
    });
    console.log("Superadmin account created!");
  }
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
