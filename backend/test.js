const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  const comments = await prisma.comment.findMany({ orderBy: { id: 'desc' }, take: 10 });
  console.log(JSON.stringify(comments, null, 2));
}
main().catch(console.error).finally(()=>prisma.$disconnect());
