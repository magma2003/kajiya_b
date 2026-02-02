const request = require('supertest');
const app = require('../server.js');
const pool = require('../src/config/db.js');

describe('Pruebas de Autenticación y Roles', () => {
    let adminToken;
    let userToken;

    // Conexión cerrada correctamente después de los tests
    afterAll(async () => {
        await pool.end();
    });

    // Test 1: Login de Usuario normal
    test('Debe loguear un usuario normal y devolver un token', async () => {
        const res = await request(app)
            .post('/api/usuarios/login')
            .send({
                email: 'cliente@gmail.com',
                password: '1234'
            });
        
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('token');
        userToken = res.body.token;
    });

    // Test 2: Acceso denegado a Crear Producto (Rol USER)
    test('Debe denegar la creación de producto a un rol USER (403)', async () => {
        const res = await request(app)
            .post('/api/productos')
            .set('Authorization', `Bearer ${userToken}`)
            .send({
                nombre: "Katana de Prueba",
                precio: 100,
                stock: 5
            });
        
        expect(res.statusCode).toEqual(403);
        expect(res.body.error).toMatch(/Acceso denegado/);
    });

    // Test 3: Edicion sin token
    test('Debe devolver 401 si se intenta editar perfil sin token', async () => {
        const res = await request(app)
            .put('/api/usuarios/perfil')
            .send({ nombres: "Hacker" });
        expect(res.statusCode).toEqual(401);
    });

    // Test 1.1 Login de Admin para obtener token de administrador
    test('Debe loguear un administrador y devolver un adminToken', async () => {
        const res = await request(app)
            .post('/api/usuarios/login')
            .send({
                email: 'admin@kajiya.com',
                password: '1234'
            });
        
        expect(res.statusCode).toEqual(200);
        adminToken = res.body.token;
    });

    // Test 4: Crear Producto con datos inválidos (precio negativo)
    test('No debe permitir crear productos con precio negativo (Usando adminToken)', async () => {
        const res = await request(app)
            .post('/api/productos')
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
                nombre: "Katana Maldita",
                precio: -50,
                stock: 10,
                image_url: "http://img.com"
            });

        expect(res.statusCode).toEqual(400);
        expect(res.body.error).toBe("El precio y el stock no pueden ser negativos.");
    });

});