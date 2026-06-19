const express = require('express');
const cors = require('cors');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
app.use(cors());

// Folder uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Host Admin Dashboard langsung dari Gateway (Biar gampang diakses)
app.use('/admin-dashboard', express.static(path.join(__dirname, 'admin-dashboard')));

// Route ke Auth & User Service (Port 3001)
app.use('/api/auth', createProxyMiddleware({ target: 'http://localhost:3001/api/auth', changeOrigin: true }));
app.use('/api/users', createProxyMiddleware({ target: 'http://localhost:3001/api/users', changeOrigin: true }));

// Route ke Recipe & Social Service (Port 3002)
app.use('/api/recipes', createProxyMiddleware({ target: 'http://localhost:3002/api/recipes', changeOrigin: true }));
app.use('/api/social', createProxyMiddleware({ target: 'http://localhost:3002/api/social', changeOrigin: true }));
app.use('/api/admin', createProxyMiddleware({ target: 'http://localhost:3002/api/admin', changeOrigin: true }));
app.use('/api/app', createProxyMiddleware({ target: 'http://localhost:3002/api/app', changeOrigin: true }));

app.get('/', (req, res) => res.json({ message: "Welcome to API Gateway (PlateQ Microservices)!" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 [GATEWAY] API Gateway berjalan di http://localhost:${PORT}`);
});
