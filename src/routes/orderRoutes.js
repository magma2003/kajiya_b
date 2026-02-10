const express = require('express');
const router = express.Router();
const { crearPedido } = require('../controllers/orderController');
const { verifyToken } = require('../middlewares/verifyToken.middleware');

router.post('/', verifyToken, crearPedido);

module.exports = router;