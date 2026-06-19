const express = require('express');
const cors = require('cors');
require('dotenv').config();

const recipeRoutes = require('./routes/recipeRoutes');
const adminRoutes = require('./routes/adminRoutes');
const socialRoutes = require('./routes/socialRoutes');
const appRoutes = require('./routes/appRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/recipes', recipeRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/social', socialRoutes);
app.use('/api/app', appRoutes);

const PORT = 3002;
app.listen(PORT, () => {
  console.log(`🍳 [RECIPE SERVICE] berjalan di http://localhost:${PORT}`);
});
