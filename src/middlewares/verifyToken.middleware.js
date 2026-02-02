const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    try {
        const Authorization = req.header("Authorization");

        if (!Authorization) {
            return res.status(401).json({ error: "No se proporcionó un token" });
        }

        const token = Authorization.split("Bearer ")[1];

        const payload = jwt.verify(token, process.env.JWT_SECRET);
        req.user = payload;
        next();
    } catch (error) {
        res.status(401).json({ error: "Token no válido o expirado" });
    }
};

module.exports = { verifyToken };