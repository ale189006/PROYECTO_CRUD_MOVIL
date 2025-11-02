-- =============================================
-- Base de datos para Sistema CRUD de Productos
-- =============================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS `proyecto_crud` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE `proyecto_crud`;

-- =============================================
-- Tabla: categorias
-- =============================================
CREATE TABLE IF NOT EXISTS `categorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `icono` varchar(50) DEFAULT NULL,
  `color` varchar(7) DEFAULT '#007bff',
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Tabla: productos
-- =============================================
CREATE TABLE IF NOT EXISTS `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categoria_id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `imagen_url` varchar(255) DEFAULT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `fk_productos_categoria` (`categoria_id`),
  KEY `idx_nombre` (`nombre`),
  KEY `idx_activo` (`activo`),
  CONSTRAINT `fk_productos_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Datos de ejemplo para categorías
-- =============================================
INSERT INTO `categorias` (`nombre`, `descripcion`, `icono`, `color`, `activo`) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología', 'fas fa-laptop', '#007bff', 1),
('Ropa', 'Vestimenta y accesorios de moda', 'fas fa-tshirt', '#28a745', 1),
('Hogar', 'Artículos para el hogar y decoración', 'fas fa-home', '#ffc107', 1),
('Deportes', 'Equipos y accesorios deportivos', 'fas fa-dumbbell', '#dc3545', 1),
('Libros', 'Libros y material educativo', 'fas fa-book', '#6f42c1', 1);

-- =============================================
-- Datos de ejemplo para productos
-- =============================================
INSERT INTO `productos` (`categoria_id`, `nombre`, `descripcion`, `precio`, `stock`, `imagen_url`, `sku`, `activo`) VALUES
(1, 'Laptop HP Pavilion', 'Laptop HP Pavilion 15 pulgadas, Intel i5, 8GB RAM, 256GB SSD', 899.99, 15, 'https://via.placeholder.com/300x200?text=Laptop+HP', 'LAP-HP-001', 1),
(1, 'iPhone 14', 'Apple iPhone 14 128GB, color azul', 999.00, 8, 'https://via.placeholder.com/300x200?text=iPhone+14', 'PHN-APP-001', 1),
(1, 'Samsung Galaxy S23', 'Samsung Galaxy S23 256GB, color negro', 849.99, 12, 'https://via.placeholder.com/300x200?text=Galaxy+S23', 'PHN-SAM-001', 1),
(2, 'Camiseta Nike', 'Camiseta deportiva Nike Dri-FIT, talla M', 29.99, 50, 'https://via.placeholder.com/300x200?text=Camiseta+Nike', 'CLT-NKE-001', 1),
(2, 'Jeans Levis 501', 'Jeans clásicos Levis 501, talla 32', 79.99, 25, 'https://via.placeholder.com/300x200?text=Jeans+Levis', 'CLT-LEV-001', 1),
(3, 'Sofá 3 plazas', 'Sofá moderno 3 plazas, color gris', 599.99, 5, 'https://via.placeholder.com/300x200?text=Sofa+3+Plazas', 'HOG-SOF-001', 1),
(3, 'Mesa de centro', 'Mesa de centro de madera, estilo moderno', 199.99, 8, 'https://via.placeholder.com/300x200?text=Mesa+Centro', 'HOG-MES-001', 1),
(4, 'Pelota de fútbol', 'Pelota de fútbol oficial, tamaño 5', 24.99, 30, 'https://via.placeholder.com/300x200?text=Pelota+Futbol', 'DEP-PEL-001', 1),
(4, 'Raqueta de tenis', 'Raqueta de tenis Wilson Pro Staff', 149.99, 10, 'https://via.placeholder.com/300x200?text=Raqueta+Tenis', 'DEP-RAQ-001', 1),
(5, 'Clean Code', 'Libro Clean Code de Robert C. Martin', 39.99, 20, 'https://via.placeholder.com/300x200?text=Clean+Code', 'LIB-CLE-001', 1),
(5, 'JavaScript: The Good Parts', 'Libro JavaScript: The Good Parts de Douglas Crockford', 34.99, 15, 'https://via.placeholder.com/300x200?text=JS+Good+Parts', 'LIB-JS-001', 1);

-- =============================================
-- Índices adicionales para optimización
-- =============================================
CREATE INDEX `idx_categorias_activo` ON `categorias` (`activo`);
CREATE INDEX `idx_productos_precio` ON `productos` (`precio`);
CREATE INDEX `idx_productos_stock` ON `productos` (`stock`);

-- =============================================
-- Vistas útiles para consultas frecuentes
-- =============================================

-- Vista: Productos con información de categoría
CREATE OR REPLACE VIEW `v_productos_categorias` AS
SELECT 
    p.id,
    p.nombre,
    p.descripcion,
    p.precio,
    p.stock,
    p.imagen_url,
    p.sku,
    p.activo,
    p.fecha_creacion,
    c.id as categoria_id,
    c.nombre as categoria_nombre,
    c.color as categoria_color,
    c.icono as categoria_icono
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = 1 AND c.activo = 1;

-- Vista: Categorías con conteo de productos
CREATE OR REPLACE VIEW `v_categorias_productos` AS
SELECT 
    c.id,
    c.nombre,
    c.descripcion,
    c.icono,
    c.color,
    c.activo,
    c.fecha_creacion,
    c.fecha_actualizacion,
    COUNT(p.id) as total_productos,
    COUNT(CASE WHEN p.activo = 1 THEN 1 END) as productos_activos
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id;

-- =============================================
-- Procedimientos almacenados útiles
-- =============================================

DELIMITER //

-- Procedimiento: Actualizar stock de producto
CREATE PROCEDURE `sp_actualizar_stock`(
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_operacion ENUM('sumar', 'restar')
)
BEGIN
    DECLARE stock_actual INT DEFAULT 0;
    
    -- Obtener stock actual
    SELECT stock INTO stock_actual FROM productos WHERE id = p_producto_id;
    
    -- Actualizar stock según operación
    IF p_operacion = 'sumar' THEN
        UPDATE productos SET stock = stock + p_cantidad WHERE id = p_producto_id;
    ELSEIF p_operacion = 'restar' THEN
        UPDATE productos SET stock = GREATEST(0, stock - p_cantidad) WHERE id = p_producto_id;
    END IF;
    
    -- Retornar nuevo stock
    SELECT stock FROM productos WHERE id = p_producto_id;
END //

-- Procedimiento: Obtener estadísticas generales
CREATE PROCEDURE `sp_estadisticas_generales`()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM categorias WHERE activo = 1) as total_categorias,
        (SELECT COUNT(*) FROM productos WHERE activo = 1) as total_productos,
        (SELECT COUNT(*) FROM productos WHERE stock > 0 AND activo = 1) as productos_con_stock,
        (SELECT COUNT(*) FROM productos WHERE stock = 0 AND activo = 1) as productos_sin_stock,
        (SELECT AVG(precio) FROM productos WHERE activo = 1) as precio_promedio,
        (SELECT SUM(stock * precio) FROM productos WHERE activo = 1) as valor_total_inventario;
END //

DELIMITER ;

-- =============================================
-- Triggers para auditoría
-- =============================================

-- Trigger: Log de cambios en productos
CREATE TABLE IF NOT EXISTS `productos_log` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `producto_id` int(11) NOT NULL,
    `accion` enum('INSERT','UPDATE','DELETE') NOT NULL,
    `datos_anteriores` json DEFAULT NULL,
    `datos_nuevos` json DEFAULT NULL,
    `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_producto_id` (`producto_id`),
    KEY `idx_fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //

CREATE TRIGGER `tr_productos_after_update` 
AFTER UPDATE ON `productos`
FOR EACH ROW
BEGIN
    INSERT INTO productos_log (producto_id, accion, datos_anteriores, datos_nuevos)
    VALUES (
        NEW.id, 
        'UPDATE',
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'precio', OLD.precio,
            'stock', OLD.stock,
            'activo', OLD.activo
        ),
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'precio', NEW.precio,
            'stock', NEW.stock,
            'activo', NEW.activo
        )
    );
END //

DELIMITER ;

-- =============================================
-- Comentarios finales
-- =============================================

/*
ESTRUCTURA DE LA BASE DE DATOS:
- categorias: Almacena las categorías de productos
- productos: Almacena los productos con relación a categorías
- productos_log: Tabla de auditoría para cambios en productos

CARACTERÍSTICAS:
- Codificación UTF-8 para soporte de caracteres especiales
- Índices optimizados para consultas frecuentes
- Vistas para consultas complejas
- Procedimientos almacenados para operaciones comunes
- Triggers para auditoría automática
- Datos de ejemplo para testing

USO:
1. Ejecutar este script en MySQL/MariaDB
2. Configurar la conexión en backend/config/database.php
3. La API estará lista para usar con datos de ejemplo
*/
