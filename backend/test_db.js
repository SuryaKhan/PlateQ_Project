const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const recipes = await prisma.recipe.findMany({
    where: {
      title: { contains: 'bakso' }
    }
  });
  console.log("SEARCH BAKSO:", recipes.map(r => r.title));

  const all = await prisma.recipe.findMany();
  console.log("ALL TITLES:", all.map(r => r.title));
}

main().catch(console.error).finally(() => prisma.$disconnect());
