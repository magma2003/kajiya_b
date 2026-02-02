const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const loginUser = async (req, res) => {
    const { email, password } = req.body;
    try {
        const result = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
        const user = result.rows[0];

        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({ error: "Credenciales incorrectas" });
        }

        // Generamos el Token
        const token = jwt.sign(
            { id: user.id, 
                email: user.email, 
                role: user.role 
            },
            process.env.JWT_SECRET //|| 'secret_kajiya'
            ,
            { expiresIn: '1h' }
        );

        delete user.password;
        res.json({ token, user });
    } catch (error) {
        res.status(500).json({ error: "Error en el servidor" });
    }
};


const registerUser = async (req, res) => {
    const { nombres, paterno, materno, rut, email, password, calle, numero, comuna, region } = req.body;

    try {
        // 1. Encriptación de seguridad
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 2. Inserción en la base de datos
        const query = `
            INSERT INTO usuarios 
            (nombres, apellido_paterno, apellido_materno, rut, email, password, calle, numero, comuna, region)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            RETURNING id, email, nombres;
        `;
        
        const values = [nombres, paterno, materno, rut, email, hashedPassword, calle, numero, comuna, region];
        const result = await pool.query(query, values);

        res.status(201).json({ 
            message: "Usuario registrado con éxito", 
            user: result.rows[0] 
        });
    } catch (error) {
        console.error("Error en registro:", error.message);
        if (error.code === '23505') { // Error de duplicado en Postgres
            return res.status(400).json({ error: "El email o RUT ya están registrados." });
        }
        res.status(500).json({ error: "Error al crear el usuario." });
    }
};

const updateUser = async (req, res) => {
    const { id } = req.user; 
    const { nombres, apellido_paterno, apellido_materno, calle, numero, comuna, region } = req.body;

    try {
        const query = `
            UPDATE usuarios 
            SET nombres = $1, apellido_paterno = $2, apellido_materno = $3, 
                calle = $4, numero = $5, comuna = $6, region = $7
            WHERE id = $8
            RETURNING id, nombres, apellido_paterno, apellido_materno, email, rut, role, calle, numero, comuna, region;
        `;
        const values = [nombres, apellido_paterno, apellido_materno, calle, numero, comuna, region, id];
        const result = await pool.query(query, values);

        res.json({ message: "Perfil actualizado", user: result.rows[0] });
    } catch (error) {
        res.status(500).json({ error: "Error al actualizar el perfil" });
    }
};

module.exports = { loginUser, registerUser, updateUser };