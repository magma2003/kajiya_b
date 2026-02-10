const pool = require('../config/db');

const crearPedido = async (req, res) => {
    const { id: usuario_id, role } = req.user;
    const { cart, total } = req.body;

    // Bloqueo de seguridad: El admin no puede comprar
    if (role === 'admin') {
        return res.status(403).json({ error: "Los Maestros Forjadores no pueden realizar compras." });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // 1. Insertar en la tabla 'pedidos'
        const pedidoQuery = `
            INSERT INTO pedidos (usuario_id, total, estado) 
            VALUES ($1, $2, 'completed') 
            RETURNING id;
        `;
        const pedidoRes = await client.query(pedidoQuery, [usuario_id, total]);
        const pedidoId = pedidoRes.rows[0].id;

        // 2. Insertar cada item en 'pedido_producto'
        for (const item of cart) {
            const detalleQuery = `
                INSERT INTO pedido_producto (pedido_id, producto_id, cantidad, precio_unitario)
                VALUES ($1, $2, $3, $4);
            `;
            await client.query(detalleQuery, [pedidoId, item.id, item.quantity, item.precio]);

            // 3. Descontar stock de la tabla productos
            await client.query('UPDATE productos SET stock = stock - $1 WHERE id = $2', [item.quantity, item.id]);
        }

        await client.query('COMMIT');
        res.status(201).json({ message: "La forja ha procesado tu pedido", pedidoId });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Error en la transacción:", error);
        res.status(500).json({ error: "Error al procesar la compra real." });
    } finally {
        client.release();
    }
};

module.exports = { crearPedido };