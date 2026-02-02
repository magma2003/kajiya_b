const express = require('express');
const router = express.Router();
const { loginUser ,registerUser} = require('../controllers/userController');
const { verifyToken } = require('../middlewares/verifyToken.middleware');
const { updateUser } = require('../controllers/userController');
const pool = require('../config/db');

router.post('/login', loginUser);
router.post('/register', registerUser); // Endpoint: /api/usuarios/register
router.put('/perfil', verifyToken, updateUser);

// Ruta protegida para obtener datos del perfil
router.get('/perfil', verifyToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuarios WHERE id = $1', [req.user.id]);
        const user = result.rows[0];
        delete user.password;
        res.json(user);
    } catch (error) {
        res.status(500).send("Error al obtener perfil");
    }
});

module.exports = router;