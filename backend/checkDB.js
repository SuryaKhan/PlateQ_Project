require('dotenv').config();
const prisma = require('./db');

async function main() {
  const categories = await prisma.category.findMany();
  console.log("Categories:", categories);

  const recipes = await prisma.recipe.findMany({ select: { id: true, title: true, categoryId: true } });
  console.log("Recipes:", recipes);
}

main().finally(() => prisma.$disconnect());
