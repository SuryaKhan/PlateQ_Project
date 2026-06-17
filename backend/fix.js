const fs = require('fs');
let data = fs.readFileSync('prisma/schema.prisma', 'utf8');
data = data.replace(/provider = "postgresql"/g, 'provider = "sqlite"');
data = data.replace(/\/\/ Enum Hak Akses[\s\S]*?enum Role \{[\s\S]*?\}/g, '');
data = data.replace(/role\s+Role\s+@default\(USER\)/g, 'role String @default("USER")');
fs.writeFileSync('prisma/schema.prisma', data);
