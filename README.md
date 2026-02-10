# ⚔️ Kajiya - Tienda de Katanas

Bienvenido a la **Forja Kajiya**, una aplicación Full Stack diseñada para la gestión y venta de armas artesanales. Este proyecto implementa autenticación robusta, gestión de roles y un catálogo interactivo con filtros avanzados.

---

## 🚀 Estructura del Proyecto

El proyecto está dividido en dos partes principales:

* **Frontend**: Desarrollado con React y Bootstrap.

* **Backend**: Desarrollado con Node.js, Express y PostgreSQL.

---

### 🛠️ Tecnologías Utilizadas

### 1. Backend
* **Node.js & Express**: Servidor y API REST.
* **PostgreSQL**: Base de datos relacional.
* **JWT (JSON Web Tokens)**: Autenticación segura.
* **Bcrypt.js**: Encriptación de contraseñas.
* **Jest & Supertest**: Pruebas unitarias y de integración.

### 2. Frontend
* **React**: Biblioteca para la interfaz de usuario.
* **Context API**: Gestión de estados globales (Usuario y Carrito).
* **Bootstrap**: Estilizado y componentes responsivos.
* **LocalStorage**: Persistencia de sesión y carrito.

---

#### ⚙️ Configuración e Instalación

### 1. Requisitos Previos
* Node.js instalado.
* Instancia de PostgreSQL activa.

### 2. Variables de Entorno (.env)
Crea un archivo `.env` en la carpeta **backend** con los siguientes datos:
```env
PORT=3000
DB_USER=tu_usuario
DB_HOST=localhost
DB_PASSWORD=tu_password
DB_NAME=kajiya_db
JWT_SECRET=tu_secreto_super_seguro


### 3. Instalación
En ambas carpetas (front y back), ejecutar para sus dependencias:
* npm install


### 4. Ejecución
Backend: 
* npm run dev (usando nodemon) o npm start.

Frontend: 
* npm run dev (si usas Vite).


### 5. EPruebas (Testing)
El backend cuenta con pruebas de integridad y seguridad. Para ejecutarlas, sitúate en la carpeta del servidor y ejecutar:
* npm test

---

## 🛣️ Endpoints de la API

### 👤 Autenticación y Usuarios

Método,Ruta,Descripción,Acceso
POST,/api/usuarios/login,Inicia sesión y devuelve un JWT con el role.,Público
POST,/api/usuarios/register,Registra un nuevo cliente con contraseña encriptada.,Público
PUT,/api/usuarios/perfil,"Actualiza datos del usuario autenticado (nombres, dirección).",Usuario/Admin


### ⚔️ Catálogo de Productos

Método,Ruta,Descripción,Acceso
GET,/api/productos,Obtiene la lista completa de armas para la tienda.,Público
POST,/api/productos,Forja un nuevo producto. Valida precios positivos.,Admin
PUT,/api/productos/:id,Modifica stock o detalles de un arma existente.,Admin
DELETE,/api/productos/:id,Elimina un producto de la forja de datos.,Admin

---


### DEPLOY
Backend: 
* https://kajiya-b.onrender.com/

Frontend: 
* https://kajiya-f.vercel.app/