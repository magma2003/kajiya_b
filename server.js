require('dotenv').config();

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const userRoutes = require('./src/routes/userRoutes');
const productRoutes = require('./src/routes/productRoutes');

const pool = require('./src/config/db');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Rutas base de prueba
app.get('/', (req, res) => {
  res.send({ message: "Bienvenido a la Forja de Kajiya API" });
});

// Uso de rutas
app.use('/api/usuarios', userRoutes);
app.use('/api/productos', productRoutes);

app.listen(PORT, () => {
  console.log(`🔥 Servidor Kajiya activo en http://localhost:${PORT}`);
});