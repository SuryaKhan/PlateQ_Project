require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  const cats = await prisma.category.findMany();
  console.log('Categories:', cats);
  if (cats.length === 0) {
    console.log('Inserting categories...');
    await prisma.category.createMany({
      data: [
        { id: 1, name: 'Nasi' },
        { id: 2, name: 'Mie' },
        { id: 3, name: 'Minuman' },
        { id: 4, name: 'Dessert' },
      ],
      skipDuplicates: true
    });
    console.log('Inserted.');
    // update all recipes to category 1
    await prisma.recipe.updateMany({ data: { categoryId: 1 } });
    console.log('Updated existing recipes to category 1');
  }
}
main().finally(() => prisma.$disconnect());
