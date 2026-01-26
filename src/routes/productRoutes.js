const express = require('express');
const router = express.Router();
const { getProductos } = require('../controllers/productController');

// Definimos la ruta raíz (que será /api/productos)
router.get('/', getProductos);

module.exports = router;