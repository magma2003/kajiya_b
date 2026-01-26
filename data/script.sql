-- 0. Creacion BD KAJIYA
CREATE DATABASE kajiya;

-- 1. Activo el autogeneracion de UUID que es mas seguro que SERIAL para usuarios y pedidos
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabla de Categorías (Katanas, Tantos, Wakizashis, etc.)
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
	descripcion TEXT,
	estado BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabla de Usuarios
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    rut VARCHAR(12) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password TEXT NOT NULL,
	foto TEXT,
	role VARCHAR(20) DEFAULT 'client' CHECK (role IN ('admin', 'client')),
	estado BOOLEAN DEFAULT TRUE,
    calle VARCHAR(255),
    numero VARCHAR(20),
    comuna VARCHAR(100) NOT NULL,
    region INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabla de Productos (El inventario del Administrador)
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(7, 0) NOT NULL CHECK (precio >= 0),
    stock INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    categoria_id INTEGER REFERENCES categorias(id) ON DELETE SET NULL,
	estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tabla de Pedidos
CREATE TABLE pedidos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    total DECIMAL(9, 0) NOT NULL,
    estado VARCHAR(20) DEFAULT 'pending', -- pending, completed, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Tabla de Detalle del Pedido
CREATE TABLE pedido_producto (
    id SERIAL PRIMARY KEY,
    pedido_id UUID REFERENCES pedidos(id) ON DELETE CASCADE,
    producto_id INTEGER REFERENCES productos(id),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(7, 0) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 7. Triger para que el producto llegue a 0 se desactive
CREATE OR REPLACE FUNCTION actualizar_estado()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.stock = 0 THEN
    NEW.estado := FALSE;
  ELSE
    NEW.estado := TRUE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_estado
BEFORE INSERT OR UPDATE ON productos
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado();

--8 carga datos pruebas
-- 1. Insertar Categorías
INSERT INTO categorias (nombre, descripcion) VALUES 
('Katanas', 'Espadas largas tradicionales con hoja curva de un solo filo.'),
('Tantos', 'Dagas japonesas de hoja recta o ligeramente curva.'),
('Wakizashis', 'Espadas cortas tradicionales usadas junto a la katana.');

-- 2. Insertar Usuarios (Admin y Cliente) clave 1234
INSERT INTO usuarios (rut, nombres, apellido_paterno, apellido_materno, email, password, role, foto) VALUES 
('1234','Hattori', 'Hanzo', 'The Master', 'admin@kajiya.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin'),
('4321','Kenji', 'Sato', 'Tanaka', 'cliente@gmail.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'client', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kenji');

-- 3. Insertar Productos Iniciales
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES 
(
    'Katana Muramasa', 
    'Hoja de acero al carbono forjada con técnicas ancestrales. Filo extremo.', 
    350000, 
    5, 
    'https://images.unsplash.com/photo-1590256157391-76503c80653f?q=80&w=1000&auto=format&fit=crop', 
    (SELECT id FROM categorias WHERE nombre = 'Katanas')
),
(
    'Tanto Imperial', 
    'Daga de oficial con acabados en oro y empuñadura de piel de raya.', 
    120000, 
    2, 
    'https://images.unsplash.com/photo-1518381165239-688005391c49?q=80&w=1000&auto=format&fit=crop', 
    (SELECT id FROM categorias WHERE nombre = 'Tantos')
),
(
    'Wakizashi de Práctica', 
    'Ideal para entrenamiento de Iaido, sin filo real para seguridad.', 
    85000, 
    0, 
    'https://images.unsplash.com/photo-1594132176008-0387b927237e?q=80&w=1000&auto=format&fit=crop', 
    (SELECT id FROM categorias WHERE nombre = 'Wakizashis')
);