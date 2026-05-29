const { register, login } = require('./controllers/authController');

const mockReq = (body) => ({ body });
const mockRes = () => {
    const res = {};
    res.status = (code) => { res.statusCode = code; return res; };
    res.json = (data) => { res.data = data; return res; };
    return res;
};

async function test() {
    console.log("Testing Register...");
    const req1 = mockReq({ username: 'testuser', email: 'test@example.com', password: 'password123', name: 'Test User' });
    const res1 = mockRes();
    await register(req1, res1);
    console.log("Register Result:", res1.statusCode, res1.data);

    console.log("\nTesting Login...");
    const req2 = mockReq({ username: 'testuser', password: 'password123' });
    const res2 = mockRes();
    await login(req2, res2);
    console.log("Login Result:", res2.statusCode, res2.data);
}

test().catch(console.error);
