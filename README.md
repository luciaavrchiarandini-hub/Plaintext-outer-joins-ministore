# MiniStore — Auditoría de Inventario y Ventas con `OUTER JOIN`

Repositorio de práctica de SQL aplicado a la auditoría de calidad de datos en **MiniStore**, utilizando `LEFT JOIN`, `RIGHT JOIN` y `FULL OUTER JOIN` para detectar productos sin rotación y registros huérfanos en el historial de transacciones.

## Estructura del repositorio

```text
outer-joins-ministore/
├── schema.sql
├── soluciones.sql
└── README.md
```

---

## Análisis técnico y preguntas de negocio

### 1. ¿Por qué usaste `LEFT JOIN` para la Consulta 1 y no `INNER JOIN`? ¿Qué se perdería si usaras `INNER JOIN`?

El objetivo de la Consulta 1 es auditar el **catálogo completo de productos** para identificar cuáles nunca se vendieron. Al colocar `productos` como tabla izquierda en un `LEFT JOIN`, el motor preserva obligatoriamente los 9 artículos del catálogo aunque no tengan filas coincidentes en `ventas`.

Si se utilizara un `INNER JOIN`, la consulta devolvería únicamente la intersección entre ambas tablas (solo los 7 productos que registraron al menos una venta) y **se perderían por completo los productos `108` (`Hub USB-C 7p`) y `109` (`Parlante Bluetooth`)**, ocultando justamente el inventario inmovilizado que el equipo de operaciones necesita detectar.

---

### 2. ¿Por qué usaste `RIGHT JOIN` para la Consulta 2? ¿Qué tabla está a la izquierda y cuál a la derecha en tu consulta?

En la Consulta 2 la prioridad es conservar **el 100% de las transacciones registradas en `ventas`** para verificar si existe alguna operación asociada a un artículo inexistente en el maestro de productos.

* **Tabla a la izquierda (`FROM`):** `productos`
* **Tabla a la derecha (`RIGHT JOIN`):** `ventas`

Al mantener `productos` a la izquierda y `ventas` a la derecha, el `RIGHT JOIN` garantiza que aparezcan las 10 ventas históricas, dejando al descubierto la **venta `10` (con `producto_id = 999`)** que no tiene correspondencia en el catálogo.

---

### 3. ¿Qué representan los valores `NULL` en cada resultado?

En SQL, `NULL` no equivale a cero ni a texto vacío: indica **ausencia de coincidencia** en la tabla relacionada durante la unión.

* **`venta_id` en `NULL` (Consulta 1 — `LEFT JOIN`):** Significa que el producto existe en el catálogo oficial, pero no posee ninguna transacción asociada en `ventas`. En los datos de MiniStore, ocurre con el **`Hub USB-C 7p` (`producto_id = 108`)** y el **`Parlante Bluetooth` (`producto_id = 109`)**, confirmando que tienen cero unidades vendidas.
* **`producto_id` de `productos` en `NULL` (Consulta 2 — `RIGHT JOIN`):** Significa que la venta existe en el historial transaccional, pero el código de producto cargado no existe en la tabla maestra `productos`. En los datos de MiniStore, ocurre en la **`venta_id = 10` (del `2024-03-25`, con `producto_id = 999`)**, evidenciando un registro huérfano por error de carga o falta de integridad referencial.

---

### 4. ¿Cuándo usarías `FULL OUTER JOIN` en un caso real de negocio?

Un `FULL OUTER JOIN` es ideal en **procesos de conciliación, migración de sistemas y auditorías integrales de datos**, donde se necesita detectar discrepancias en ambos extremos al mismo tiempo sin descartar ningún registro:

* **Conciliación contable y bancaria:** Cruzar los registros de cobros del sistema interno (ERP) contra el extracto bancario externo para detectar en una sola vista tanto facturas cobradas que aún no impactaron en el banco como transferencias recibidas que no tienen factura asignada.
* **Migración de bases de datos:** Comparar una tabla origen (sistema legado) contra una tabla destino (nuevo Data Warehouse) para auditar qué registros faltan migrar y cuáles quedaron duplicados o sin origen válido.
