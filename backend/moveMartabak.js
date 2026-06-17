require('dotenv').config();
const prisma = require('./db');

async function main() {
  await prisma.recipe.update({
    where: { id: 7 },
    data: { categoryId: 4 }
  });
  console.log("Martabak moved to Dessert");
}

main().finally(() => prisma.$disconnect());
