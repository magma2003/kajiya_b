const express = require('express');
const router = express.Router();
const { loginUser ,registerUser} = require('../controllers/userController');
const { verifyToken } = require('../middlewares/verifyToken.middleware');
const { updateUser } = require('../controllers/userController');
const pool = require('../config/db');

router.post('/login', loginUser);
router.post('/register', registerUser);
router.put('/perfil', verifyToken, updateUser);

// Ruta protegida para obtener datos del perfil
router.get('/perfil', verifyToken, async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT id, nombres, apellido_paterno, apellido_materno, rut, email, foto, role, estado, calle, numero, comuna, region FROM usuarios WHERE id = $1', 
            [req.user.id]
        );
        if (result.rows.length === 0) return res.status(404).send("Usuario no encontrado");
        const user = result.rows[0];
        delete user.password;
        res.json({ user });
    } catch (error) {
        res.status(500).send("Error al obtener perfil");
    }
});

module.exports = router;