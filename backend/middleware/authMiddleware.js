const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  
  if (!authHeader) return res.status(401).json({ error: "Token nggak ada bro!" });

  // Kita pecah dan paksa ambil urutan ke-2 (index 1)
  const headerParts = authHeader.split(' ');
  
  // NAH INI DIA! ADA DI UJUNGNYA BIAR JADI STRING:
  const token = headerParts[1]; 

  if (!token || token === "null" || token === "undefined") {
    return res.status(401).json({ error: "Format token salah atau tidak ada!" });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'rahasia_plateq_2026', (err, user) => {
    if (err) {
      console.log("Gagal karena:", err.message);
      return res.status(403).json({ error: "Token nggak valid!" });
    }
    req.user = user;
    next();
  });
};

module.exports = authenticateToken;