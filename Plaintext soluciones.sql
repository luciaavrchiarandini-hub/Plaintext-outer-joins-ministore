-- ══════════════════════════════════════════
-- MiniStore — Soluciones con Outer JOINs
-- Motor: SQL Server (SSMS)
-- Autor: Lucía Chiarandini
-- Fecha: 18/11/2026
-- ══════════════════════════════════════════


-- ── CONSULTA 1: LEFT JOIN ─────────────────
-- Pregunta de negocio: ¿Qué productos del catálogo nunca fueron vendidos?
-- Tabla izquierda: productos (preserva los 9 productos del catálogo)
-- Tabla derecha: ventas (devuelve NULL cuando el producto no tiene ventas)

-- 1A. Vista completa del catálogo con sus ventas asociadas (incluye los 9 productos)
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio,
    v.venta_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;

-- 1B. Filtro directo con WHERE IS NULL para aislar únicamente los productos sin ventas (IDs 108 y 109)
SELECT
    p.producto_id,
    p.nombre,
    p.categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v ON p.producto_id = v.producto_id
WHERE v.venta_id IS NULL
ORDER BY p.producto_id;


-- ── CONSULTA 2: RIGHT JOIN ────────────────
-- Pregunta de negocio: ¿Existen ventas registradas con productos
-- que no figuran en nuestro catálogo? (posible error de carga de datos)
-- Tabla izquierda: productos
-- Tabla derecha: ventas (preserva las 10 transacciones de ventas)

-- 2A. Vista completa de ventas cruzadas contra el catálogo (incluye las 10 ventas)
SELECT
    p.producto_id AS catalogo_producto_id,
    p.nombre      AS nombre_producto,
    v.venta_id,
    v.producto_id AS venta_producto_id,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
RIGHT JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY v.venta_id;

-- 2B. Filtro directo con WHERE IS NULL para aislar la venta huérfana (venta_id = 10, producto_id = 999)
SELECT
    v.venta_id,
    v.producto_id AS venta_producto_id,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
RIGHT JOIN ventas v ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
ORDER BY v.venta_id;


-- ── CONSULTA 3: FULL OUTER JOIN ───────────
-- Pregunta de negocio: Vista completa de auditoría que muestre
-- todos los productos y todas las ventas sin perder ninguna fila,
-- identificando tanto productos sin ventas como ventas sin producto.

-- 3A. Auditoría integral de ambas tablas (9 coincidencias + 2 productos sin venta + 1 venta huérfana = 12 filas)
SELECT
    p.producto_id AS catalogo_producto_id,
    p.nombre      AS nombre_producto,
    p.categoria,
    v.venta_id,
    v.producto_id AS venta_producto_id,
    v.cantidad,
    v.fecha_venta
FROM productos p
FULL OUTER JOIN ventas v ON p.producto_id = v.producto_id
ORDER BY p.producto_id, v.venta_id;

-- 3B. Filtro directo con WHERE IS NULL para aislar todas las discrepancias de integridad
SELECT
    p.producto_id AS catalogo_producto_id,
    p.nombre      AS nombre_producto,
    v.venta_id,
    v.producto_id AS venta_producto_id,
    v.fecha_venta
FROM productos p
FULL OUTER JOIN ventas v ON p.producto_id = v.producto_id
WHERE p.producto_id IS NULL
   OR v.venta_id IS NULL
ORDER BY p.producto_id, v.venta_id;
