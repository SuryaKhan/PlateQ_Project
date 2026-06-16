const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.findFirst({
    where: {
      OR: [
        { username: 'aqil' },
        { email: 'aqil' }
      ]
    }
  });
  console.log("User found:", user);
}

main().finally(() => prisma.$disconnect());
