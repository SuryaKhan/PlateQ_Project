require('dotenv').config();
const prisma = require('./db');

async function main() {
  await prisma.category.upsert({
    where: { id: 1 },
    update: { name: 'Makanan' },
    create: { id: 1, name: 'Makanan' }
  });

  // Since we changed Nasi to Makanan, recipes that were Nasi are now Makanan.
  // Now let's delete Mie (id: 2) if it has no recipes, or move its recipes to Makanan.
  await prisma.recipe.updateMany({
    where: { categoryId: 2 },
    data: { categoryId: 1 }
  });

  await prisma.category.deleteMany({
    where: { name: 'Mie' }
  });
  
  await prisma.category.deleteMany({
    where: { name: 'Nasi' } // In case id wasn't 1
  });

  console.log("Categories updated to Makanan, Minuman, Dessert");
}

main().finally(() => prisma.$disconnect());
