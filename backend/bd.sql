-- Creación de la base de datos en MySQL
CREATE DATABASE restaurante;
USE restaurante;

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    username VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('administrador', 'vendedor') NOT NULL
);

-- Tabla de productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(10, 2) NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    fecha_vencimiento DATE
);

-- Tabla de ventas
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Tabla de productos desperdiciados
CREATE TABLE productos_desperdiciados (
    id_desperdicio INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    cantidad INT NOT NULL,
    fecha_desperdicio DATE NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


// Para crear un reporte de ventas
SELECT v.id_venta, v.fecha_venta, u.nombre AS vendedor, v.total,
       GROUP_CONCAT(p.nombre SEPARATOR ', ') AS productos
FROM ventas v
JOIN usuarios u ON v.id_usuario = u.id_usuario
JOIN detalle_ventas dv ON v.id_venta = dv.id_venta
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY v.id_venta
ORDER BY v.fecha_venta DESC;


// Ventas totales por día:

SELECT DATE(fecha_venta) AS fecha, SUM(total) AS venta_total
FROM ventas
GROUP BY DATE(fecha_venta)
ORDER BY fecha DESC;

// Top 10 productos más vendidos:

SELECT p.nombre, SUM(dv.cantidad) AS total_vendido, SUM(dv.subtotal) AS ingreso_total
FROM detalle_ventas dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY dv.id_producto
ORDER BY total_vendido DESC
LIMIT 10;

// Productos con bajo stock (menos de 10 unidades):

SELECT nombre, stock
FROM productos
WHERE stock < 10
ORDER BY stock ASC;

// Reporte de desperdicios:

SELECT p.nombre, SUM(pd.cantidad) AS total_desperdiciado, 
       SUM(pd.cantidad * p.precio_compra) AS costo_total
FROM productos_desperdiciados pd
JOIN productos p ON pd.id_producto = p.id_producto
GROUP BY pd.id_producto
ORDER BY total_desperdiciado DESC;

// Margen de ganancia por producto:

SELECT p.nombre, 
       p.precio_venta, 
       p.precio_compra, 
       (p.precio_venta - p.precio_compra) AS margen,
       ((p.precio_venta - p.precio_compra) / p.precio_compra * 100) AS porcentaje_margen
FROM productos p
ORDER BY porcentaje_margen DESC;

// Ahora, vamos a crear procedimientos almacenados para automatizar estos reportes:
DELIMITER //

-- 1. Ventas totales por día
CREATE PROCEDURE sp_ventas_por_dia(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    SELECT DATE(fecha_venta) AS fecha, SUM(total) AS venta_total
    FROM ventas
    WHERE fecha_venta BETWEEN fecha_inicio AND fecha_fin
    GROUP BY DATE(fecha_venta)
    ORDER BY fecha DESC;
END //

-- 2. Top productos más vendidos
CREATE PROCEDURE sp_top_productos(IN top_n INT)
BEGIN
    SELECT p.nombre, SUM(dv.cantidad) AS total_vendido, SUM(dv.subtotal) AS ingreso_total
    FROM detalle_ventas dv
    JOIN productos p ON dv.id_producto = p.id_producto
    GROUP BY dv.id_producto
    ORDER BY total_vendido DESC
    LIMIT top_n;
END //

-- 3. Rendimiento de ventas por usuario
CREATE PROCEDURE sp_rendimiento_usuarios()
BEGIN
    SELECT u.nombre, u.apellido, COUNT(v.id_venta) AS total_ventas, SUM(v.total) AS monto_total
    FROM usuarios u
    LEFT JOIN ventas v ON u.id_usuario = v.id_usuario
    GROUP BY u.id_usuario
    ORDER BY monto_total DESC;
END //

-- 4. Productos con bajo stock
CREATE PROCEDURE sp_productos_bajo_stock(IN limite_stock INT)
BEGIN
    SELECT nombre, stock
    FROM productos
    WHERE stock < limite_stock
    ORDER BY stock ASC;
END //

-- 5. Reporte de desperdicios
CREATE PROCEDURE sp_reporte_desperdicios(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    SELECT p.nombre, SUM(pd.cantidad) AS total_desperdiciado, 
           SUM(pd.cantidad * p.precio_compra) AS costo_total
    FROM productos_desperdiciados pd
    JOIN productos p ON pd.id_producto = p.id_producto
    WHERE pd.fecha_desperdicio BETWEEN fecha_inicio AND fecha_fin
    GROUP BY pd.id_producto
    ORDER BY total_desperdiciado DESC;
END //

-- 6. Margen de ganancia por producto
CREATE PROCEDURE sp_margen_ganancia()
BEGIN
    SELECT p.nombre, 
           p.precio_venta, 
           p.precio_compra, 
           (p.precio_venta - p.precio_compra) AS margen,
           ((p.precio_venta - p.precio_compra) / p.precio_compra * 100) AS porcentaje_margen
    FROM productos p
    ORDER BY porcentaje_margen DESC;
END //

DELIMITER ;

// Para usar estos procedimientos almacenados, puedes llamarlos así:
CALL sp_ventas_por_dia('2024-01-01', '2024-12-31');
CALL sp_top_productos(10);
CALL sp_rendimiento_usuarios();
CALL sp_productos_bajo_stock(10);
CALL sp_reporte_desperdicios('2024-01-01', '2024-12-31');
CALL sp_margen_ganancia();

Estos reportes proporcionarán al dueño del restaurante información valiosa sobre:

//Tendencias de ventas diarias
//Productos más populares
//Rendimiento de los empleados
//Gestión de inventario
//Control de desperdicios
//Análisis de rentabilidad por producto