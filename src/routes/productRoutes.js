const express = require('express');
const router = express.Router();
const { getProductos, createProduct } = require('../controllers/productController');
const { verifyToken } = require('../middlewares/verifyToken.middleware');
const { isAdmin } = require('../middlewares/isAdmin.middleware');


router.get('/', getProductos);
router.post('/', verifyToken, isAdmin, createProduct);

module.exports = router;