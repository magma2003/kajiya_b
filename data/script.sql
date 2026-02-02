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
    stock INTEGER NOT NULL CHECK (stock >= 0),
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
('Wakizashis', 'Espadas cortas tradicionales usadas junto a la katana.'),
('Dagas', 'Armas cortas como Tanto y cuchillos ceremoniales.'),
('Espadas Largas', 'Espadas de gran longitud como Nodachis y Odachis.'),
('Espadas de Madera', 'Bokkens y espadas de entrenamiento de madera.');

-- 2. Insertar Usuarios (Admin y Cliente) clave 1234
INSERT INTO usuarios (rut, nombres, apellido_paterno, apellido_materno, email, password, role, foto) VALUES 
('1234','Hattori', 'Hanzo', 'The Master', 'admin@kajiya.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin'),
('4321','Kenji', 'Sato', 'Tanaka', 'cliente@kajiya.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'client', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kenji');

-- 3. Insertar Productos Iniciales
-- 1. Katanas (ID 1)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Katana Muramasa', 'Hoja forjada en acero T10 con Hamon real.', 850000, 3, 'https://placehold.co/600x400/1a1a1a/e63946?text=Katana+Muramasa', 1),
('Katana Musashi', 'Doble anillo en la tsuba, acero damasco.', 450000, 5, 'https://placehold.co/600x400/1a1a1a/e63946?text=Katana+Musashi', 1),
('Katana Sakura', 'Acabados en seda rosa y flores de cerezo.', 210000, 8, 'https://placehold.co/600x400/1a1a1a/e63946?text=Katana+Sakura', 1),
('Katana Onimaru', 'Hoja negra con filo rojo carmesí.', 550000, 2, 'https://placehold.co/600x400/1a1a1a/e63946?text=Katana+Onimaru', 1),
('Katana Imperial', 'Accesorios bañados en oro de 24k.', 1500000, 1, 'https://placehold.co/600x400/1a1a1a/e63946?text=Katana+Imperial', 1);

-- 2. Tantos (ID 2)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Tanto Shirasaya', 'Montura minimalista en madera natural.', 120000, 4, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tanto+Shirasaya', 2),
('Tanto Kaiken', 'Daga oculta usada tradicionalmente por mujeres.', 95000, 10, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tanto+Kaiken', 2),
('Tanto de Combate', 'Hoja gruesa diseñada para penetración.', 150000, 6, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tanto+Combat', 2),
('Tanto Ceremonial', 'Grabados de dragón en la hoja de acero.', 185000, 3, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tanto+Ceremonial', 2),
('Tanto Hira-Zukuri', 'Hoja plana sin nervio central (Shinogi).', 135000, 5, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tanto+Hira', 2);

-- 3. Wakizashis (ID 3)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Wakizashi Guardian', 'El compañero fiel de la Katana.', 320000, 4, 'https://placehold.co/600x400/1a1a1a/e63946?text=Wakizashi+Guardian', 3),
('Wakizashi Ronin', 'Acero al carbono con pátina envejecida.', 280000, 2, 'https://placehold.co/600x400/1a1a1a/e63946?text=Wakizashi+Ronin', 3),
('Wakizashi de Honor', 'Koshirae elegante en seda azul oscura.', 350000, 3, 'https://placehold.co/600x400/1a1a1a/e63946?text=Wakizashi+Honor', 3),
('Wakizashi Elite', 'Hoja plegada con 2048 capas.', 420000, 1, 'https://placehold.co/600x400/1a1a1a/e63946?text=Wakizashi+Elite', 3),
('Wakizashi Practicante', 'Ideal para Iaido en espacios reducidos.', 195000, 7, 'https://placehold.co/600x400/1a1a1a/e63946?text=Wakizashi+Practice', 3);

-- 4. Dagas (ID 4)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Daga Kunai Set', 'Juego de 3 dagas de lanzamiento equilibradas.', 45000, 20, 'https://placehold.co/600x400/1a1a1a/e63946?text=Kunai+Set', 4),
('Daga de Ritual', 'Hoja de obsidiana decorativa con mango tallado.', 80000, 4, 'https://placehold.co/600x400/1a1a1a/e63946?text=Ritual+Dagger', 4),
('Daga Yoroi-oshi', 'Diseñada para perforar armaduras samurai.', 110000, 2, 'https://placehold.co/600x400/1a1a1a/e63946?text=Yoroi+Oshi', 4),
('Sais de Acero', 'Par de dagas tridentes para defensa.', 90000, 6, 'https://placehold.co/600x400/1a1a1a/e63946?text=Sais+Steel', 4),
('Daga Táctica Black', 'Recubrimiento antireflejo y mango de polímero.', 55000, 15, 'https://placehold.co/600x400/1a1a1a/e63946?text=Tactical+Dagger', 4);

-- 5. Espadas Largas (ID 5)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Nodachi O-Katana', 'Espada de gran longitud (130cm).', 1250000, 2, 'https://placehold.co/600x400/1a1a1a/e63946?text=Nodachi+Katana', 5),
('Odachi Kage', 'La sombra del campo de batalla. Acero negro.', 1100000, 3, 'https://placehold.co/600x400/1a1a1a/e63946?text=Odachi+Kage', 5),
('Nagaki Master', 'Hoja extra larga con empuñadura reforzada.', 980000, 2, 'https://placehold.co/600x400/1a1a1a/e63946?text=Nagaki+Master', 5),
('Espada Nodachi Zen', 'Equilibrio superior a pesar de su tamaño.', 1350000, 1, 'https://placehold.co/600x400/1a1a1a/e63946?text=Nodachi+Zen', 5),
('Odachi Ancestral', 'Réplica de pieza de museo, acero plegado.', 2500000, 1, 'https://placehold.co/600x400/1a1a1a/e63946?text=Odachi+Ancestral', 5);

-- 6. Espadas de Madera (ID 6)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Bokken Roble Rojo', 'Madera densa para práctica de contacto.', 45000, 25, 'https://placehold.co/600x400/1a1a1a/e63946?text=Bokken+Red+Oak', 6),
('Bokken Roble Blanco', 'Más ligero y flexible para Kata.', 55000, 18, 'https://placehold.co/600x400/1a1a1a/e63946?text=Bokken+White+Oak', 6),
('Suburito Pesado', 'Bokken extra grueso para fortalecer hombros.', 65000, 12, 'https://placehold.co/600x400/1a1a1a/e63946?text=Suburito+Trainer', 6),
('Shinai de Bambú', 'Espada de láminas para Kendo competitivo.', 38000, 30, 'https://placehold.co/600x400/1a1a1a/e63946?text=Shinai+Bambu', 6),
('Jo de Madera', 'Bastón corto complementario para entrenamiento.', 25000, 40, 'https://placehold.co/600x400/1a1a1a/e63946?text=Jo+Staff', 6);