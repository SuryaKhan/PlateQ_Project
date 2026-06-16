require('dotenv').config();
const prisma = require('./db');

async function main() {
  await prisma.category.createMany({
    data: [
      { id: 1, name: 'Nasi' },
      { id: 2, name: 'Mie' },
      { id: 3, name: 'Minuman' },
      { id: 4, name: 'Dessert' }
    ],
    skipDuplicates: true
  });
  console.log("Categories seeded");
  await prisma.recipe.updateMany({ data: { categoryId: 1 } });
  console.log("Recipes updated");
}

main().finally(() => prisma.$disconnect());
