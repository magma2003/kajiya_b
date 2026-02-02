const pool = require('../config/db');

const getProductos = async (req, res) => {
    try {
        const query = `
            SELECT p.*, c.nombre AS categoria_nombre 
            FROM productos p
            LEFT JOIN categorias c ON p.categoria_id = c.id
            ORDER BY p.id ASC`;
        
        const { rows } = await pool.query(query);
        res.json(rows);
    } catch (error) {
        console.error("Error al obtener productos:", error);
        res.status(500).json({ message: "Error al obtener el catálogo" });
    }
};

const createProduct = async (req, res) => {
    const { nombre, descripcion, precio, stock, image_url, categoria_id} = req.body;

    if (Number(precio) < 0 || Number(stock) < 0) {
        return res.status(400).json({ error: "El precio y el stock no pueden ser negativos." });
    }

    try {
        const query = `
            INSERT INTO productos (nombre, descripcion, precio, stock, image_url,categoria_id)
            VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`;
        const values = [nombre, descripcion, precio, stock, image_url, categoria_id];
        const result = await pool.query(query, values);
        
        res.status(201).json({ message: "Nueva arma forjada", producto: result.rows[0] });
    } catch (error) {
        res.status(500).json({ error: "Error al forjar el producto" });
    }
};

module.exports = { getProductos, createProduct };