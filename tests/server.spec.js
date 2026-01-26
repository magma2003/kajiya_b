const request = require("supertest");
const server = require("../index");

describe("Operaciones CRUD de cafes", () => {

    // GET CAFES
    describe('GET /cafes', () => {

        it('retorna un array y status 200', async () => {
        const response = await request(server).get('/cafes')

        expect(response.status).toBe(200)
        expect(Array.isArray(response.body)).toBe(true)
        })

    }) 

    // POST CAFES
    describe('POST /cafes', () => {

        it('crea un nuevo café cuando el id no existe', async () => {
            const nuevoCafe = {
                id: 10,
                nombre: 'Starbucks'
            }

            const response = await request(server)
            .post('/cafes')
            .send(nuevoCafe)

            expect(response.status).toBe(201)
            expect(Array.isArray(response.body)).toBe(true)
        })

        it('retorna 400 si el id del café ya existe', async () => {
            const cafeDuplicado = {
                id: 1,
                nombre: 'Cortado'
            }

            const response = await request(server)
            .post('/cafes')
            .send(cafeDuplicado)

            expect(response.status).toBe(400)
        })
    })

    // PUT CAFES
    describe('PUT /cafes/:id', () => {

        it('retorna 400 si el id del parámetro no coincide con el body', async () => {
            const response = await request(server)
            .put('/cafes/1')
            .send({
                id: 2,
                nombre: 'Café incorrecto'
            })

            expect(response.status).toBe(400)
        })

        it('retorna 404 si el café no existe', async () => {
            const response = await request(server)
            .put('/cafes/999')
            .send({
                id: 999,
                nombre: 'Café inexistente'
            })

            expect(response.status).toBe(404)
        })

        it('actualiza un café existente y retorna el arreglo', async () => {
            const cafeActualizado = {
            id: 1,
            nombre: 'Cortado Doble'
            }

            const response = await request(server)
            .put('/cafes/1')
            .send(cafeActualizado)

            expect(response.status).toBe(200)
            expect(Array.isArray(response.body)).toBe(true)
        })

    })

    // DELETE CAFES
    describe('DELETE /cafes/:id', () => {

        it('elimina un café existente cuando se envía token', async () => {
            const response = await request(server)
            .delete('/cafes/1')
            .set('Authorization', 'fake-jwt-token')

            expect(response.status).toBe(200)
            expect(Array.isArray(response.body)).toBe(true)
        })

        it('retorna 404 si el café no existe', async () => {
            const response = await request(server)
            .delete('/cafes/999')
            .set('Authorization', 'fake-jwt-token')

            expect(response.status).toBe(404)
            expect(response.body.message).toBeDefined()
        })

        it('retorna 400 si no se envía token', async () => {
            const response = await request(server)
            .delete('/cafes/1')

            expect(response.status).toBe(400)
            expect(response.body.message).toBeDefined()
        })

    })

});
