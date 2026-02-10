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
('Tachi', 'Espada tradicional japonesa, antecesora de la katana.'),
('Espadas Largas', 'Espadas de gran longitud como Nodachis y Odachis.'),
('Espadas de Madera', 'Bokkens y espadas de entrenamiento de madera.');

-- 2. Insertar Usuarios (Admin y Cliente) clave 1234
INSERT INTO usuarios (rut, nombres, apellido_paterno, apellido_materno, email, password, role, foto,comuna,region) VALUES 
('1234','Hattori', 'Hanzo', 'The Master', 'admin@kajiya.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin','Valparaiso','5'),
('4321','Kenji', 'Sato', 'Tanaka', 'cliente@kajiya.com', '$2b$10$Wjj60AJ7s9yZoXqkt5DaDOTadJgts/ppBk/PiUGZZAG.7/Si91nL.', 'client', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Kenji','Valparaiso','5');

-- 3. Insertar Productos Iniciales
-- 1. Katanas (ID 1)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Katana Muramasa', 'Hoja forjada en acero T10 con Hamon real.', 850000, 3, 'https://katana.store/cdn/shop/files/muramasa-wakizashi-587.webp', 1),
('Katana Musashi', 'Doble anillo en la tsuba, acero damasco.', 450000, 5, 'https://katana.store/cdn/shop/products/black-dragon-katana-710.webp', 1),
('Katana Ghost of Tsushima', 'Acabados basados en video juego de PS.', 210000, 8, 'https://katana.store/cdn/shop/files/ghost-of-tsushima-katana-465.webp', 1),
('Katana Fire Dragon ', 'Hoja negra con filo rojo carmesí.', 550000, 2, 'https://katana.store/cdn/shop/products/fire-dragon-katana-349.webp', 1),
('Katana Black Dragon', 'Accesorios bañados en oro de 24k.', 1500000, 0, 'https://katana.store/cdn/shop/products/black-dragon-katana-710.webp', 1);

-- 2. Tantos (ID 2)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Tanto T10', 'Hoja forjada en acero T10 con Hamon real.', 120000, 4, 'https://katana.store/cdn/shop/files/t10-tanto-280.webp', 2),
('Tanto Combat', 'Hoja gruesa diseñada para penetración.', 150000, 6, 'https://katana.store/cdn/shop/files/combat-tanto-403.webp', 2),
('Tanto Shirasaya', 'Grabados de dragón en la hoja de acero.', 185000, 3, 'https://katana.store/cdn/shop/files/shirasaya-tanto-497.webp', 2),
('Tanto Military', 'Hoja combina la venerada artesanía de la espada japonesa con la estética militar contemporánea.', 135000, 5, 'https://katana.store/cdn/shop/files/tanto-military-253.webp', 2);

-- 3. Wakizashis (ID 3)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Wakizashi Ninja', 'El compañero fiel de la Katana.', 320000, 4, 'https://katana.store/cdn/shop/files/ninja-wakizashi-950.webp', 3),
('Wakizashi Ko', 'Acero al carbono con pátina envejecida.', 280000, 2, 'https://katana.store/cdn/shop/files/ko-wakizashi-472.webp', 3),
('Wakizashi Full Tang', 'Koshirae elegante en seda azul oscura.', 350000, 3, 'https://katana.store/cdn/shop/files/full-tang-wakizashi-800.webp', 3),
('Wakizashi Bizen', 'Hoja plegada con 2048 capas.', 420000, 1, 'https://katana.store/cdn/shop/files/bizen-wakizashi-509.webp', 3),
('Wakizashi Training', 'Ideal para Iaido en espacios reducidos.', 195000, 7, 'https://katana.store/cdn/shop/files/training-wakizashi-237.webp', 3);

-- 4. Dagas (ID 4)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Tachi Cherry Blossom', 'Daga decorativa con diseño de flores de ciruelo.', 45000, 20, 'https://katana.store/cdn/shop/files/cherry-blossom-tachi-832.webp', 4),
('Tachi Gray', 'Daga de acero gris con acabado elegante.', 80000, 4, 'https://katana.store/cdn/shop/files/gray-tachi-931.webp', 4),
('Tachi Red', 'Daga roja con detalles decorativos.', 110000, 2, 'https://katana.store/cdn/shop/files/red-tachi-539.webp', 4),
('Tachi T10', 'Daga forjada en acero T10.', 55000, 15, 'https://katana.store/cdn/shop/files/t10-tachi-454.webp', 4);

-- 5. Espadas Largas (ID 5)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Sword Enma', 'El ilustre espadachín Zoro Roronoa empuñó esta extraordinaria espada, famosa por su filo inigualable.', 1250000, 2, 'https://katana.store/cdn/shop/files/enma-sword-652.webp', 5),
('Sword Inosuke', 'Nuestra espada Inosuke destaca por su patrón de hoja dentada , que evoca el estilo de combate bestial de Inosuke.', 1100000, 3, 'https://katana.store/cdn/shop/files/inosuke-sword-882.webp', 5),
('Sword Sasuke', 'Conocida frecuentemente como la " Espada Cortadora de Hierba ", la Kusanagi ocupa un lugar legendario en el mundo de Naruto.', 1350000, 1, 'https://katana.store/cdn/shop/files/sasuke-sword-935.webp', 5),
('Sword Rurouni Kenshin ', 'Se popularizó gracias al manga y anime -Rurouni Kenshin- en el que el protagonista , Himura Kenshin.', 1450000, 10, 'https://katana.store/cdn/shop/files/rurouni-kenshin-sword-314.webp', 5),
('Sword Japan Tachi', 'Vaina negra adornada con motivos florales, es la verdadera encarnación de la elegancia atemporal y el profundo simbolismo de la cultura japonesa.', 2500000, 1, 'https://katana.store/cdn/shop/files/tachi-sword-japan-616.webp', 5);

-- 6. Espadas de Madera (ID 6)
INSERT INTO productos (nombre, descripcion, precio, stock, image_url, categoria_id) VALUES
('Bokken Shirasaya', 'Esta exquisita espada de entrenamiento imita el peso y la sensación de una katana tradicional.', 45000, 25, 'https://katana.store/cdn/shop/files/shirasaya-bokken-372.webp', 6),
('Bokken Kendo', 'El Kendo Bokken es una herramienta esencial tanto para principiantes como para practicantes avanzados de Kendo, el arte marcial tradicional japonés.', 55000, 18, 'https://katana.store/cdn/shop/files/kendo-bokken-895.webp', 6),
('Bokken Daito', 'Espada de madera de alta calidad es perfecta para perfeccionar tus habilidades de forma segura y efectiva', 65000, 12, 'https://katana.store/cdn/shop/files/bokken-daito-682.webp', 6),
('Bokken Straight', 'Un puente hacia las auténticas artes marciales japonesas.', 25000, 40, 'https://katana.store/cdn/shop/files/straight-bokken-491.webp', 6);