require('dotenv').config();
const { register, login } = require('./controllers/authController');

const mockReq = (body) => ({ body });
const mockRes = () => {
    const res = {};
    res.status = (code) => { res.statusCode = code; return res; };
    res.json = (data) => { res.data = data; return res; };
    return res;
};

async function test() {
    require('dotenv').config();
    console.log("DB URL IS: ", process.env.DATABASE_URL);
    console.log("\nTesting Login...");
    const req2 = mockReq({ username: 'superadmin', password: 'admin123' });
    const res2 = mockRes();
    await login(req2, res2);
    console.log("Login Result:", res2.statusCode, res2.data);
}

test().catch(console.error);
