-- SHOCK 88 | Modelo lógico v1.0.0-RC1 | 23 octubre 2026
-- Adaptacion compatible con MariaDB 10.4 / InnoDB / utf8mb4
-- DIFERENCIA RESPECTO AL RC1 ORIGINAL: utf8mb4_0900_ai_ci -> utf8mb4_unicode_ci
-- SOLO PARA INSTALACION LIMPIA EN UNA BASE DE DATOS DE PRUEBAS VACIA.
-- NO REEJECUTAR SOBRE shock88 EXISTENTE SIN REVISAR COLISIONES/RESPALDO.
-- CANDIDATO A VALIDACION: ejecutar sobre MariaDB 10.4 de pruebas limpio; no usar en produccion sin aprobar pruebas.
-- Reglas aprobadas: invitado no acumula ni se vincula; 10 ventas pagadas / semestre calendario;
-- cupón 10% una vez por semestre, sin descuentos acumulados; reseña tras entrega;
-- vendedor valida transferencias; pedidos sólo se cancelan completos.
-- APROBADO: periodos fijos Ene-Jun / Jul-Dic para todos los clientes.
-- PENDIENTE DE POLÍTICA COMERCIAL (el esquema ya admite estas opciones): vigencia del cupón;
-- tratamiento de recompensa ya canjeada ante cancelación de venta generadora; alcance de IVA/CFDI.
-- Todas las categorías cuentan; cada pedido pagado de cliente identificado suma UNA venta.
-- Convención: importes MXN DECIMAL(13,2); DATETIME(6) guardados en UTC desde la aplicación.
-- Tipos de estado protegidos con CHECK; flujos de negocio se validan también en servicios PHP.

CREATE DATABASE IF NOT EXISTS shock88
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shock88;
-- Conexiones PHP deben fijar la zona horaria a UTC para columnas DATETIME(6).
SET time_zone = '+00:00';

-- A. Usuarios / seguridad / tienda
CREATE TABLE sucursales (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL,
 direccion VARCHAR(255) NULL,
 activa BOOLEAN NOT NULL DEFAULT TRUE,
 creada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(150) NOT NULL,
 email VARCHAR(190) NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 ultimo_acceso_en DATETIME(6) NULL,
 UNIQUE KEY uk_usuario_email (email)
) ENGINE=InnoDB;

CREATE TABLE roles (
 id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 codigo VARCHAR(35) NOT NULL,
 nombre VARCHAR(90) NOT NULL,
 UNIQUE KEY uk_rol_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE permisos (
 id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 codigo VARCHAR(90) NOT NULL,
 descripcion VARCHAR(220) NULL,
 UNIQUE KEY uk_permiso_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE usuario_roles (
 usuario_id BIGINT UNSIGNED NOT NULL,
 rol_id SMALLINT UNSIGNED NOT NULL,
 PRIMARY KEY(usuario_id,rol_id),
 KEY ix_ur_rol (rol_id),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE rol_permisos (
 rol_id SMALLINT UNSIGNED NOT NULL,
 permiso_id SMALLINT UNSIGNED NOT NULL,
 PRIMARY KEY(rol_id,permiso_id),
 KEY ix_rp_permiso (permiso_id),
 FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
 FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE clientes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NULL COMMENT 'NULL: cliente presencial sin cuenta web',
 nombre VARCHAR(150) NOT NULL,
 email VARCHAR(190) NULL,
 telefono VARCHAR(30) NULL,
 identidad_verificada_en DATETIME(6) NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_cliente_usuario (usuario_id),
 KEY ix_cliente_telefono (telefono),
 KEY ix_cliente_email (email),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- B. Catálogo y variantes
CREATE TABLE categorias (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 padre_id BIGINT UNSIGNED NULL,
 nombre VARCHAR(120) NOT NULL,
 slug VARCHAR(160) NOT NULL,
 activa BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE KEY uk_categoria_slug (slug),
 KEY ix_cat_padre (padre_id),
 FOREIGN KEY (padre_id) REFERENCES categorias(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE productos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 categoria_id BIGINT UNSIGNED NOT NULL,
 nombre VARCHAR(180) NOT NULL,
 slug VARCHAR(200) NOT NULL,
 descripcion TEXT NULL,
 costo_unitario DECIMAL(13,2) NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_producto_slug (slug),
 KEY ix_producto_categoria_activo (categoria_id,activo),
 CONSTRAINT ck_producto_costo CHECK (costo_unitario >= 0),
 FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE colores (
 id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(70) NOT NULL,
 codigo_hex CHAR(7) NULL,
 UNIQUE KEY uk_color_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE tallas (
 id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 etiqueta VARCHAR(35) NOT NULL,
 UNIQUE KEY uk_talla_etiqueta (etiqueta)
) ENGINE=InnoDB;

CREATE TABLE presentaciones (
 id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(90) NOT NULL,
 UNIQUE KEY uk_presentacion_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE producto_variantes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 producto_id BIGINT UNSIGNED NOT NULL,
 color_id SMALLINT UNSIGNED NOT NULL,
 talla_id SMALLINT UNSIGNED NOT NULL,
 presentacion_id SMALLINT UNSIGNED NOT NULL,
 sku VARCHAR(90) NOT NULL,
 precio_venta DECIMAL(13,2) NOT NULL,
 activa BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE KEY uk_variante_sku (sku),
 UNIQUE KEY uk_variante_combinacion (producto_id,color_id,talla_id,presentacion_id),
 UNIQUE KEY uk_variante_producto_id (producto_id,id) COMMENT 'Verifica que imagen por variante corresponda al producto',
 KEY ix_variante_color (color_id),
 KEY ix_variante_talla (talla_id),
 KEY ix_variante_presentacion (presentacion_id),
 CONSTRAINT ck_variante_precio CHECK (precio_venta >= 0),
 FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
 FOREIGN KEY (color_id) REFERENCES colores(id) ON DELETE RESTRICT,
 FOREIGN KEY (talla_id) REFERENCES tallas(id) ON DELETE RESTRICT,
 FOREIGN KEY (presentacion_id) REFERENCES presentaciones(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE producto_imagenes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 producto_id BIGINT UNSIGNED NOT NULL,
 variante_id BIGINT UNSIGNED NULL COMMENT 'NULL: imagen general del producto',
 ruta VARCHAR(500) NOT NULL,
 texto_alternativo VARCHAR(200) NULL,
 orden SMALLINT UNSIGNED NOT NULL DEFAULT 0,
 es_principal BOOLEAN NOT NULL DEFAULT FALSE,
 KEY ix_imagen_producto_orden (producto_id,orden),
 KEY ix_imagen_variante (variante_id),
 KEY ix_imagen_producto_variante (producto_id,variante_id),
 FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
 FOREIGN KEY (variante_id) REFERENCES producto_variantes(id) ON DELETE RESTRICT,
 FOREIGN KEY (producto_id,variante_id) REFERENCES producto_variantes(producto_id,id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Importación y trazabilidad de productos desde Excel/CSV.
CREATE TABLE importaciones (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 archivo_nombre VARCHAR(255) NOT NULL,
 archivo_sha256 CHAR(64) NOT NULL,
 tipo VARCHAR(18) NOT NULL DEFAULT 'PRODUCTOS',
 estado VARCHAR(16) NOT NULL DEFAULT 'PENDIENTE',
 filas_total INT UNSIGNED NOT NULL DEFAULT 0,
 filas_ok INT UNSIGNED NOT NULL DEFAULT 0,
 filas_error INT UNSIGNED NOT NULL DEFAULT 0,
 creada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 finalizada_en DATETIME(6) NULL,
 KEY ix_importacion_usuario_fecha (usuario_id,creada_en),
 KEY ix_importacion_hash (archivo_sha256),
 CONSTRAINT ck_importacion_tipo CHECK (tipo IN ('PRODUCTOS','INVENTARIO')),
 CONSTRAINT ck_importacion_estado CHECK (estado IN ('PENDIENTE','PROCESANDO','COMPLETADA','CON_ERRORES','FALLIDA')),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE importacion_errores (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 importacion_id BIGINT UNSIGNED NOT NULL,
 numero_fila INT UNSIGNED NOT NULL,
 campo VARCHAR(90) NULL,
 codigo_error VARCHAR(80) NOT NULL,
 descripcion VARCHAR(500) NOT NULL,
 KEY ix_importacion_error_lote (importacion_id,numero_fila),
 FOREIGN KEY (importacion_id) REFERENCES importaciones(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- C. Existencias y carritos
CREATE TABLE inventario (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 sucursal_id BIGINT UNSIGNED NOT NULL,
 variante_id BIGINT UNSIGNED NOT NULL,
 existencia_fisica INT UNSIGNED NOT NULL DEFAULT 0,
 actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_inventario_sucursal_variante (sucursal_id,variante_id),
 KEY ix_inventario_variante (variante_id),
 FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE RESTRICT,
 FOREIGN KEY (variante_id) REFERENCES producto_variantes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE carritos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cliente_id BIGINT UNSIGNED NULL,
 token_invitado_hash CHAR(64) NULL COMMENT 'Nunca guardar el token original de sesión',
 estado VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_carrito_token (token_invitado_hash),
 KEY ix_carrito_cliente_estado (cliente_id,estado),
 CONSTRAINT ck_carrito_estado CHECK (estado IN ('ACTIVO','CONVERTIDO','ABANDONADO')),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE carrito_detalles (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 carrito_id BIGINT UNSIGNED NOT NULL,
 variante_id BIGINT UNSIGNED NOT NULL,
 cantidad INT UNSIGNED NOT NULL,
 UNIQUE KEY uk_carrito_variante (carrito_id,variante_id),
 KEY ix_carrito_det_variante (variante_id),
 CONSTRAINT ck_carrito_cantidad CHECK (cantidad > 0),
 FOREIGN KEY (carrito_id) REFERENCES carritos(id) ON DELETE CASCADE,
 FOREIGN KEY (variante_id) REFERENCES producto_variantes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- D. Pedidos, reservas y pagos
CREATE TABLE pedidos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 folio VARCHAR(35) NOT NULL,
 clave_solicitud VARCHAR(100) NULL COMMENT 'Idempotencia por intento de checkout/POS; servicio debe enviarla',
 cliente_id BIGINT UNSIGNED NULL COMMENT 'NULL: compra como invitado',
 sucursal_id BIGINT UNSIGNED NOT NULL,
 vendedor_usuario_id BIGINT UNSIGNED NULL,
 canal VARCHAR(10) NOT NULL,
 nombre_contacto VARCHAR(150) NOT NULL,
 email_contacto VARCHAR(190) NULL,
 telefono_contacto VARCHAR(30) NULL,
 estado_operativo VARCHAR(24) NOT NULL DEFAULT 'ABIERTO',
 estado_pago VARCHAR(22) NOT NULL DEFAULT 'PENDIENTE',
 estado_entrega VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
 subtotal DECIMAL(13,2) NOT NULL DEFAULT 0,
 descuento_total DECIMAL(13,2) NOT NULL DEFAULT 0,
 total DECIMAL(13,2) NOT NULL DEFAULT 0,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 pagado_en DATETIME(6) NULL,
 entregado_en DATETIME(6) NULL,
 UNIQUE KEY uk_pedido_folio (folio),
 UNIQUE KEY uk_pedido_clave_solicitud (clave_solicitud),
 KEY ix_pedido_fecha_canal (creado_en,canal),
 KEY ix_pedido_estado_fecha (estado_operativo,creado_en),
 KEY ix_pedido_pago_fecha (estado_pago,creado_en),
 KEY ix_pedido_entrega_fecha (estado_entrega,creado_en),
 KEY ix_pedido_cliente_fecha (cliente_id,creado_en),
 KEY ix_pedido_sucursal (sucursal_id),
 KEY ix_pedido_vendedor (vendedor_usuario_id),
 CONSTRAINT ck_pedido_canal CHECK (canal IN ('FISICA','ONLINE')),
 CONSTRAINT ck_pedido_operativo CHECK (estado_operativo IN ('ABIERTO','CONFIRMADO','CANCELACION_SOLICITADA','CANCELADO','CONCILIACION')),
 CONSTRAINT ck_pedido_pago CHECK (estado_pago IN ('PENDIENTE','APROBADO','FALLIDO','REEMBOLSO_PENDIENTE','REEMBOLSADO')),
 CONSTRAINT ck_pedido_entrega CHECK (estado_entrega IN ('PENDIENTE','PREPARANDO','LISTO_RECOGER','ENTREGADO')),
 CONSTRAINT ck_pedido_montos CHECK (subtotal >= 0 AND descuento_total >= 0 AND total >= 0 AND descuento_total <= subtotal),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
 FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE RESTRICT,
 FOREIGN KEY (vendedor_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pedido_detalles (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pedido_id BIGINT UNSIGNED NOT NULL,
 variante_id BIGINT UNSIGNED NOT NULL,
 sku_historico VARCHAR(90) NOT NULL,
 nombre_historico VARCHAR(180) NOT NULL,
 cantidad INT UNSIGNED NOT NULL,
 precio_unitario DECIMAL(13,2) NOT NULL,
 costo_unitario_historico DECIMAL(13,2) NOT NULL,
 descuento_linea DECIMAL(13,2) NOT NULL DEFAULT 0,
 KEY ix_detalle_pedido (pedido_id),
 KEY ix_detalle_variante (variante_id),
 CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
 CONSTRAINT ck_detalle_montos CHECK (precio_unitario >= 0 AND costo_unitario_historico >= 0 AND descuento_linea >= 0 AND descuento_linea <= cantidad * precio_unitario),
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
 FOREIGN KEY (variante_id) REFERENCES producto_variantes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE inventario_reservas (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pedido_detalle_id BIGINT UNSIGNED NOT NULL,
 sucursal_id BIGINT UNSIGNED NOT NULL,
 cantidad INT UNSIGNED NOT NULL,
 estado VARCHAR(14) NOT NULL DEFAULT 'ACTIVA',
 creada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 expira_en DATETIME(6) NOT NULL,
 cerrada_en DATETIME(6) NULL,
 UNIQUE KEY uk_reserva_detalle (pedido_detalle_id),
 KEY ix_reserva_vencimiento (estado,expira_en),
 KEY ix_reserva_sucursal (sucursal_id),
 CONSTRAINT ck_reserva_cantidad CHECK (cantidad > 0),
 CONSTRAINT ck_reserva_estado CHECK (estado IN ('ACTIVA','CONSUMIDA','VENCIDA','LIBERADA')),
 CONSTRAINT ck_reserva_fechas CHECK (expira_en > creada_en),
 FOREIGN KEY (pedido_detalle_id) REFERENCES pedido_detalles(id) ON DELETE RESTRICT,
 FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE inventario_movimientos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 inventario_id BIGINT UNSIGNED NOT NULL,
 pedido_detalle_id BIGINT UNSIGNED NULL,
 usuario_id BIGINT UNSIGNED NULL,
 tipo VARCHAR(18) NOT NULL,
 cantidad_delta INT NOT NULL,
 clave_operacion VARCHAR(140) NOT NULL COMMENT 'Idempotencia por movimiento físico',
 motivo VARCHAR(255) NULL,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_mov_clave_operacion (clave_operacion),
 KEY ix_mov_inventario_fecha (inventario_id,creado_en),
 KEY ix_mov_detalle (pedido_detalle_id),
 KEY ix_mov_usuario (usuario_id),
 CONSTRAINT ck_mov_tipo CHECK (tipo IN ('ALTA','AJUSTE','VENTA','CANCELACION')),
 CONSTRAINT ck_mov_cantidad CHECK (cantidad_delta <> 0),
 FOREIGN KEY (inventario_id) REFERENCES inventario(id) ON DELETE RESTRICT,
 FOREIGN KEY (pedido_detalle_id) REFERENCES pedido_detalles(id) ON DELETE RESTRICT,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pagos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pedido_id BIGINT UNSIGNED NOT NULL,
 metodo VARCHAR(14) NOT NULL,
 proveedor VARCHAR(14) NOT NULL,
 referencia_externa VARCHAR(190) NULL,
 monto DECIMAL(13,2) NOT NULL,
 comision DECIMAL(13,2) NOT NULL DEFAULT 0,
 estado VARCHAR(16) NOT NULL DEFAULT 'PENDIENTE',
 comprobante_ruta VARCHAR(500) NULL,
 registrado_por_usuario_id BIGINT UNSIGNED NULL,
 verificado_por_usuario_id BIGINT UNSIGNED NULL COMMENT 'Vendedor que verifica transferencia local',
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 confirmado_en DATETIME(6) NULL,
 UNIQUE KEY uk_pago_proveedor_ref (proveedor,referencia_externa),
 KEY ix_pago_pedido_estado (pedido_id,estado),
 KEY ix_pago_confirmado (confirmado_en),
 KEY ix_pago_registrador (registrado_por_usuario_id),
 KEY ix_pago_verificador (verificado_por_usuario_id),
 CONSTRAINT ck_pago_monto CHECK (monto > 0 AND comision >= 0),
 CONSTRAINT ck_pago_metodo CHECK (metodo IN ('EFECTIVO','TRANSFERENCIA','TARJETA','PAYPAL')),
 CONSTRAINT ck_pago_proveedor CHECK (proveedor IN ('LOCAL','MERCADOPAGO','PAYPAL')),
 CONSTRAINT ck_pago_estado CHECK (estado IN ('PENDIENTE','APROBADO','RECHAZADO','REEMBOLSADO','PARCIAL_REEMBOLSO')),
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
 FOREIGN KEY (registrado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
 FOREIGN KEY (verificado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pago_eventos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pago_id BIGINT UNSIGNED NULL,
 proveedor VARCHAR(14) NOT NULL,
 clave_idempotencia CHAR(64) NOT NULL,
 tipo_evento VARCHAR(120) NOT NULL,
 referencia_externa VARCHAR(190) NULL,
 payload JSON NULL COMMENT 'Excluir datos sensibles; definir politica de retencion',
 estado_procesamiento VARCHAR(16) NOT NULL DEFAULT 'RECIBIDO',
 recibido_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 procesado_en DATETIME(6) NULL,
 UNIQUE KEY uk_evento_proveedor_idem (proveedor,clave_idempotencia),
 KEY ix_evento_pago (pago_id),
 KEY ix_evento_estado_fecha (estado_procesamiento,recibido_en),
 CONSTRAINT ck_evento_estado CHECK (estado_procesamiento IN ('RECIBIDO','PROCESADO','ERROR')),
 FOREIGN KEY (pago_id) REFERENCES pagos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pedido_estado_historial (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pedido_id BIGINT UNSIGNED NOT NULL,
 usuario_id BIGINT UNSIGNED NULL,
 tipo_estado VARCHAR(15) NOT NULL DEFAULT 'OPERATIVO',
 estado_anterior VARCHAR(24) NULL,
 estado_nuevo VARCHAR(24) NOT NULL,
 nota VARCHAR(255) NULL,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 KEY ix_hist_pedido_fecha (pedido_id,creado_en),
 KEY ix_hist_usuario (usuario_id),
 CONSTRAINT ck_hist_tipo_estado CHECK (tipo_estado IN ('OPERATIVO','PAGO','ENTREGA')),
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cancelaciones (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 pedido_id BIGINT UNSIGNED NOT NULL,
 solicitado_por_usuario_id BIGINT UNSIGNED NULL,
 solicitado_por_cliente_id BIGINT UNSIGNED NULL,
 autorizado_por_usuario_id BIGINT UNSIGNED NULL,
 motivo VARCHAR(400) NOT NULL,
 estado VARCHAR(20) NOT NULL DEFAULT 'SOLICITADA',
 creada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 resuelta_en DATETIME(6) NULL,
 UNIQUE KEY uk_cancelacion_pedido (pedido_id),
 KEY ix_cancelacion_solicitante (solicitado_por_usuario_id),
 KEY ix_cancelacion_cliente (solicitado_por_cliente_id),
 KEY ix_cancelacion_autorizador (autorizado_por_usuario_id),
 CONSTRAINT ck_cancelacion_estado CHECK (estado IN ('SOLICITADA','APROBADA','RECHAZADA')),
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
 FOREIGN KEY (solicitado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
 FOREIGN KEY (solicitado_por_cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
 FOREIGN KEY (autorizado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE reembolsos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cancelacion_id BIGINT UNSIGNED NOT NULL,
 pago_id BIGINT UNSIGNED NOT NULL,
 monto DECIMAL(13,2) NOT NULL,
 estado VARCHAR(18) NOT NULL DEFAULT 'PENDIENTE',
 referencia_externa VARCHAR(190) NULL,
 solicitado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 completado_en DATETIME(6) NULL,
 KEY ix_reembolso_cancelacion (cancelacion_id),
 KEY ix_reembolso_pago (pago_id),
 CONSTRAINT ck_reembolso_monto CHECK (monto > 0),
 CONSTRAINT ck_reembolso_estado CHECK (estado IN ('PENDIENTE','COMPLETADO','FALLIDO')),
 FOREIGN KEY (cancelacion_id) REFERENCES cancelaciones(id) ON DELETE RESTRICT,
 FOREIGN KEY (pago_id) REFERENCES pagos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- E. Reseñas de compra verificada
CREATE TABLE resenas (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cliente_id BIGINT UNSIGNED NOT NULL,
 producto_id BIGINT UNSIGNED NOT NULL,
 pedido_detalle_id BIGINT UNSIGNED NOT NULL,
 estrellas TINYINT UNSIGNED NOT NULL,
 comentario TEXT NOT NULL,
 visible BOOLEAN NOT NULL DEFAULT TRUE,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 ocultado_por_usuario_id BIGINT UNSIGNED NULL,
 ocultado_en DATETIME(6) NULL,
 UNIQUE KEY uk_resena_cliente_producto (cliente_id,producto_id),
 UNIQUE KEY uk_resena_detalle (pedido_detalle_id),
 KEY ix_resena_producto_visible (producto_id,visible,creado_en),
 KEY ix_resena_ocultador (ocultado_por_usuario_id),
 CONSTRAINT ck_resena_estrellas CHECK (estrellas BETWEEN 1 AND 5),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
 FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
 FOREIGN KEY (pedido_detalle_id) REFERENCES pedido_detalles(id) ON DELETE RESTRICT,
 FOREIGN KEY (ocultado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- F. Descuentos, amigos, cupones VIP y recompensa por compras
CREATE TABLE cupones (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 codigo VARCHAR(70) NOT NULL,
 clase VARCHAR(14) NOT NULL,
 porcentaje DECIMAL(5,2) NOT NULL,
 compra_minima DECIMAL(13,2) NOT NULL DEFAULT 0,
 max_usos_total INT UNSIGNED NULL,
 max_usos_cliente INT UNSIGNED NULL,
 canal VARCHAR(10) NOT NULL DEFAULT 'AMBOS',
 alcance VARCHAR(12) NOT NULL DEFAULT 'TODOS',
 vigente_desde DATETIME(6) NULL,
 vigente_hasta DATETIME(6) NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_cupon_codigo (codigo),
 KEY ix_cupon_clase_activo (clase,activo),
 CONSTRAINT ck_cupon_clase CHECK (clase IN ('PUBLICO','AMIGOS','VIP','LEALTAD')),
 CONSTRAINT ck_cupon_porcentaje CHECK (porcentaje > 0 AND porcentaje <= 100),
 CONSTRAINT ck_cupon_canal CHECK (canal IN ('FISICA','ONLINE','AMBOS')),
 CONSTRAINT ck_cupon_alcance CHECK (alcance IN ('TODOS','PRODUCTOS','CATEGORIAS')),
 CONSTRAINT ck_cupon_compra_minima CHECK (compra_minima >= 0),
 CONSTRAINT ck_cupon_max_usos CHECK ((max_usos_total IS NULL OR max_usos_total > 0) AND (max_usos_cliente IS NULL OR max_usos_cliente > 0)),
 CONSTRAINT ck_cupon_vigencia CHECK (vigente_desde IS NULL OR vigente_hasta IS NULL OR vigente_hasta > vigente_desde)
) ENGINE=InnoDB;

-- Si alcance=PRODUCTOS, debe existir al menos una fila de cupon_productos;
-- si alcance=CATEGORIAS, al menos una fila de cupon_categorias.
-- La exclusividad de alcance se valida en el servicio de cupones.
CREATE TABLE cupon_productos (
 cupon_id BIGINT UNSIGNED NOT NULL,
 producto_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY (cupon_id,producto_id),
 KEY ix_cupon_producto_producto (producto_id),
 FOREIGN KEY (cupon_id) REFERENCES cupones(id) ON DELETE RESTRICT,
 FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cupon_categorias (
 cupon_id BIGINT UNSIGNED NOT NULL,
 categoria_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY (cupon_id,categoria_id),
 KEY ix_cupon_categoria_categoria (categoria_id),
 FOREIGN KEY (cupon_id) REFERENCES cupones(id) ON DELETE RESTRICT,
 FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cupon_asignaciones (
 cupon_id BIGINT UNSIGNED NOT NULL,
 cliente_id BIGINT UNSIGNED NOT NULL,
 asignado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 PRIMARY KEY (cupon_id,cliente_id),
 KEY ix_asignacion_cliente (cliente_id),
 FOREIGN KEY (cupon_id) REFERENCES cupones(id) ON DELETE RESTRICT,
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cupon_usos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cupon_id BIGINT UNSIGNED NOT NULL,
 pedido_id BIGINT UNSIGNED NOT NULL,
 cliente_id BIGINT UNSIGNED NULL,
 importe_descuento DECIMAL(13,2) NOT NULL,
 estado VARCHAR(12) NOT NULL DEFAULT 'RESERVADO',
 reservado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 usado_en DATETIME(6) NULL,
 UNIQUE KEY uk_cupon_uso_pedido (pedido_id) COMMENT 'Propuesta: un solo cupon por pedido',
 KEY ix_cupon_uso_cupon_fecha (cupon_id,reservado_en),
 KEY ix_cupon_uso_cliente (cliente_id,cupon_id),
 CONSTRAINT ck_cupon_uso_monto CHECK (importe_descuento >= 0),
 CONSTRAINT ck_cupon_uso_estado CHECK (estado IN ('RESERVADO','CANJEADO','REVERTIDO')),
 FOREIGN KEY (cupon_id) REFERENCES cupones(id) ON DELETE RESTRICT,
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT,
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- APROBADO: periodos SEMESTRALES FIJOS: 01-ene a 30-jun y 01-jul a 31-dic.
-- Fechas en horario comercial local (America/Tijuana); fin_exclusivo no se incluye.
-- El servicio de lealtad debe generar periodos nuevos anualmente y evitar solapamientos.
CREATE TABLE periodos_lealtad (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(90) NOT NULL,
 inicio DATE NOT NULL,
 fin_exclusivo DATE NOT NULL,
 max_recompensas_cliente TINYINT UNSIGNED NOT NULL DEFAULT 1,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE KEY uk_periodo_lealtad_inicio (inicio),
 KEY ix_periodo_lealtad_fechas (inicio,fin_exclusivo),
 CONSTRAINT ck_periodo_lealtad_fechas CHECK (fin_exclusivo > inicio),
 CONSTRAINT ck_periodo_lealtad_limite CHECK (max_recompensas_cliente = 1)
) ENGINE=InnoDB;

CREATE TABLE movimientos_lealtad (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cliente_id BIGINT UNSIGNED NOT NULL,
 periodo_id BIGINT UNSIGNED NOT NULL,
 pedido_id BIGINT UNSIGNED NULL,
 tipo VARCHAR(14) NOT NULL,
 ventas_delta INT NOT NULL COMMENT 'Cada pedido pagado identificado aporta 1 venta, sin importar las prendas',
 nota VARCHAR(255) NULL,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 UNIQUE KEY uk_lealtad_pedido_tipo (pedido_id,tipo),
 KEY ix_lealtad_cliente_periodo (cliente_id,periodo_id,creado_en),
 KEY ix_lealtad_periodo (periodo_id),
 CONSTRAINT ck_lealtad_tipo CHECK (tipo IN ('COMPRA','REVERSA','AJUSTE')),
 CONSTRAINT ck_lealtad_delta CHECK (
   (tipo='COMPRA' AND ventas_delta=1) OR
   (tipo='REVERSA' AND ventas_delta=-1) OR
   (tipo='AJUSTE' AND ventas_delta<>0)
 ),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
 FOREIGN KEY (periodo_id) REFERENCES periodos_lealtad(id) ON DELETE RESTRICT,
 FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE recompensas_cliente (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 cliente_id BIGINT UNSIGNED NOT NULL,
 periodo_id BIGINT UNSIGNED NOT NULL,
 cupon_id BIGINT UNSIGNED NOT NULL,
 pedido_generador_id BIGINT UNSIGNED NOT NULL,
 hito_ventas SMALLINT UNSIGNED NOT NULL DEFAULT 10,
 estado VARCHAR(12) NOT NULL DEFAULT 'EMITIDA',
 creada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 canjeada_en DATETIME(6) NULL,
 UNIQUE KEY uk_recompensa_cliente_periodo (cliente_id,periodo_id),
 UNIQUE KEY uk_recompensa_cupon (cupon_id),
 KEY ix_recompensa_periodo (periodo_id),
 KEY ix_recompensa_pedido (pedido_generador_id),
 CONSTRAINT ck_recompensa_hito CHECK (hito_ventas = 10),
 CONSTRAINT ck_recompensa_estado CHECK (estado IN ('EMITIDA','CANJEADA','REVOCADA','VENCIDA')),
 FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
 FOREIGN KEY (periodo_id) REFERENCES periodos_lealtad(id) ON DELETE RESTRICT,
 FOREIGN KEY (cupon_id) REFERENCES cupones(id) ON DELETE RESTRICT,
 FOREIGN KEY (pedido_generador_id) REFERENCES pedidos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- G. Gastos generales, parametros y auditoria
CREATE TABLE gasto_categorias (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 activa BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE KEY uk_gasto_categoria_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE gastos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 categoria_id BIGINT UNSIGNED NOT NULL,
 sucursal_id BIGINT UNSIGNED NOT NULL,
 registrado_por_usuario_id BIGINT UNSIGNED NOT NULL,
 fecha_gasto DATE NOT NULL,
 descripcion VARCHAR(255) NOT NULL,
 importe DECIMAL(13,2) NOT NULL,
 metodo_pago VARCHAR(18) NOT NULL,
 comprobante_ruta VARCHAR(500) NULL,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 KEY ix_gasto_fecha_categoria (fecha_gasto,categoria_id),
 KEY ix_gasto_sucursal_fecha (sucursal_id,fecha_gasto),
 KEY ix_gasto_usuario (registrado_por_usuario_id),
 CONSTRAINT ck_gasto_importe CHECK (importe > 0),
 CONSTRAINT ck_gasto_metodo CHECK (metodo_pago IN ('EFECTIVO','TRANSFERENCIA','OTRO')),
 FOREIGN KEY (categoria_id) REFERENCES gasto_categorias(id) ON DELETE RESTRICT,
 FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE RESTRICT,
 FOREIGN KEY (registrado_por_usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE configuracion (
 clave VARCHAR(100) PRIMARY KEY,
 valor VARCHAR(500) NOT NULL,
 descripcion VARCHAR(255) NULL,
 actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB;

CREATE TABLE auditoria (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NULL,
 accion VARCHAR(90) NOT NULL,
 tabla_afectada VARCHAR(80) NOT NULL,
 registro_id VARCHAR(90) NOT NULL,
 detalle JSON NULL,
 ip_origen VARCHAR(45) NULL,
 creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 KEY ix_auditoria_usuario_fecha (usuario_id,creado_en),
 KEY ix_auditoria_tabla_registro (tabla_afectada,registro_id),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Datos semilla mínimos, ajustables en la fase de implementación.
-- Semestres calendario aprobados. Periodos iniciales 2026-2030; al iniciar cada año,
-- el servicio de aplicación creará semestres futuros faltantes usando esta regla.
-- El semestre para acreditar es el correspondiente a pagado_en en America/Tijuana.
-- El cierre del semestre no elimina movimientos previos ni recompensas históricas.
INSERT IGNORE INTO periodos_lealtad
 (nombre,inicio,fin_exclusivo,max_recompensas_cliente,activo) VALUES
 ('2026-S1','2026-01-01','2026-07-01',1,TRUE),
 ('2026-S2','2026-07-01','2027-01-01',1,TRUE),
 ('2027-S1','2027-01-01','2027-07-01',1,TRUE),
 ('2027-S2','2027-07-01','2028-01-01',1,TRUE),
 ('2028-S1','2028-01-01','2028-07-01',1,TRUE),
 ('2028-S2','2028-07-01','2029-01-01',1,TRUE),
 ('2029-S1','2029-01-01','2029-07-01',1,TRUE),
 ('2029-S2','2029-07-01','2030-01-01',1,TRUE),
 ('2030-S1','2030-01-01','2030-07-01',1,TRUE),
 ('2030-S2','2030-07-01','2031-01-01',1,TRUE);
INSERT IGNORE INTO roles(codigo,nombre) VALUES
 ('ROOT','Administrador tecnico'),('PROPIETARIO','Propietario'),
 ('ADMIN','Administrador'),('VENDEDOR','Vendedor'),('CLIENTE','Cliente');
INSERT IGNORE INTO tallas(etiqueta) VALUES ('UNITALLA');
INSERT IGNORE INTO presentaciones(nombre) VALUES ('UNICA');
INSERT IGNORE INTO colores(nombre) VALUES ('SIN ESPECIFICAR');
INSERT IGNORE INTO configuracion(clave,valor,descripcion) VALUES
 ('reserva_minutos','10','Plazo comercial confirmado para la reserva temporal'),
 ('umbral_ventas_semestre','10','Beneficio del 10% al acumular 10 ventas pagadas por semestre'),
 ('max_cupones_lealtad_semestre','1','Aprobado: un cupon por semestre calendario'),
 ('lealtad_periodicidad','SEMESTRES_FIJOS','Enero-junio y julio-diciembre, segun America/Tijuana');

-- Permisos iniciales RECOMENDADOS para probar los tres portales.
-- Especificación técnica propuesta, sujeta a aprobación de la matriz por el propietario.
-- La cuenta ROOT no recibe 'cancelaciones.autorizar' ni 'reembolsos.gestionar':
-- la regla aprobada reserva la cancelación de pedidos pagados al propietario y administrador.
INSERT IGNORE INTO permisos(codigo,descripcion) VALUES
 ('catalogo.ver','Ver productos, variantes, categorias y existencias publicas'),
 ('catalogo.gestionar','Crear o editar catalogo, variantes y fotografias'),
 ('categorias.gestionar','Crear y editar categorias'),
 ('inventario.ver','Consultar inventario'),
 ('inventario.ajustar','Modificar existencias con auditoria'),
 ('ventas.crear','Registrar venta fisica'),
 ('ventas.ver','Consultar ventas'),
 ('pedidos.ver','Consultar pedidos'),
 ('pedidos.preparar','Preparar pedidos pagados'),
 ('pedidos.entregar','Registrar entrega completa'),
 ('pagos.ver','Consultar pagos'),
 ('pagos.verificar_transferencia','Verificar transferencias recibidas'),
 ('cancelaciones.autorizar','Autorizar cancelacion de pedido pagado'),
 ('reembolsos.gestionar','Gestionar reembolsos autorizados'),
 ('clientes.ver','Consultar datos comerciales de clientes'),
 ('clientes.gestionar','Gestionar clientes'),
 ('cupones.ver','Consultar cupones y condiciones'),
 ('cupones.gestionar','Crear y modificar promociones'),
 ('cupones.usar','Usar cupon permitido en un pedido'),
 ('lealtad.ver','Consultar movimientos y recompensas'),
 ('lealtad.ver_propia','Consultar fidelizacion del cliente autenticado'),
 ('resenas.crear','Publicar resena de producto entregado'),
 ('resenas.ver','Consultar reseñas'),
 ('resenas.ocultar','Ocultar reseñas con motivo y auditoria'),
 ('gastos.ver','Consultar gastos'),
 ('gastos.gestionar','Registrar y modificar gastos'),
 ('dashboard.ver','Consultar dashboard'),
 ('reportes.exportar','Exportar reportes autorizados'),
 ('usuarios.gestionar','Administrar usuarios sin poder elevar privilegios ROOT'),
 ('roles.gestionar','Editar permisos de roles no ROOT'),
 ('configuracion.gestionar','Ajustar parametros comerciales'),
 ('configuracion.tecnica','Ajustar configuracion tecnica y acceso ROOT'),
 ('auditoria.ver','Consultar bitacora'),
 ('importaciones.gestionar','Subir catalogo/inventario desde Excel o CSV'),
 ('pedidos.ver_propios','Consultar pedidos del cliente autenticado');

INSERT IGNORE INTO rol_permisos (rol_id,permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.codigo='ROOT' AND p.codigo IN ('catalogo.ver','inventario.ver','ventas.ver','pedidos.ver','pagos.ver','clientes.ver','cupones.ver','lealtad.ver','resenas.ver','gastos.ver','dashboard.ver','reportes.exportar','usuarios.gestionar','roles.gestionar','configuracion.gestionar','configuracion.tecnica','auditoria.ver','importaciones.gestionar');

INSERT IGNORE INTO rol_permisos (rol_id,permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.codigo='PROPIETARIO' AND p.codigo IN ('catalogo.ver','catalogo.gestionar','categorias.gestionar','inventario.ver','inventario.ajustar','ventas.crear','ventas.ver','pedidos.ver','pedidos.preparar','pedidos.entregar','pagos.ver','pagos.verificar_transferencia','cancelaciones.autorizar','reembolsos.gestionar','clientes.ver','clientes.gestionar','cupones.ver','cupones.gestionar','cupones.usar','lealtad.ver','resenas.ver','resenas.ocultar','gastos.ver','gastos.gestionar','dashboard.ver','reportes.exportar','usuarios.gestionar','roles.gestionar','configuracion.gestionar','auditoria.ver','importaciones.gestionar');

INSERT IGNORE INTO rol_permisos (rol_id,permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.codigo='ADMIN' AND p.codigo IN ('catalogo.ver','catalogo.gestionar','categorias.gestionar','inventario.ver','inventario.ajustar','ventas.crear','ventas.ver','pedidos.ver','pedidos.preparar','pedidos.entregar','pagos.ver','pagos.verificar_transferencia','cancelaciones.autorizar','reembolsos.gestionar','clientes.ver','clientes.gestionar','cupones.ver','cupones.gestionar','cupones.usar','lealtad.ver','resenas.ver','resenas.ocultar','gastos.ver','gastos.gestionar','dashboard.ver','reportes.exportar','usuarios.gestionar','roles.gestionar','configuracion.gestionar','auditoria.ver','importaciones.gestionar');

INSERT IGNORE INTO rol_permisos (rol_id,permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.codigo='VENDEDOR' AND p.codigo IN ('catalogo.ver','inventario.ver','ventas.crear','ventas.ver','pedidos.ver','pedidos.preparar','pedidos.entregar','pagos.ver','pagos.verificar_transferencia','clientes.ver','cupones.ver','cupones.usar');

INSERT IGNORE INTO rol_permisos (rol_id,permiso_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permisos p
WHERE r.codigo='CLIENTE' AND p.codigo IN ('catalogo.ver','pedidos.ver_propios','lealtad.ver_propia','cupones.usar','resenas.crear');

-- No se generan usuarios ni contraseñas por defecto. Registrar ROOT mediante un instalador seguro.
-- Ninguna venta invitado suma fidelizacion. El comprobante de pago debe ser confirmado.
-- El cupon de lealtad puede tener vigente_hasta NULL si se decide no limitar caducidad.
-- Manejo de factura/IVA pendiente de autorización comercial/fiscal.

-- Reglas que no se pueden expresar por CHECK/FK simple y deben validarse en servicios PHP:
-- 1) Disponible = existencia_fisica - reservas ACTIVAS aun vigentes.
-- 2) SELECT ... FOR UPDATE del inventario en cada camino de reservar/consumir/liberar;
--    el conteo y nuevas reservas deben operar bajo el mismo bloqueo transaccional.
-- 3) Reseñas: pedido_entrega=ENTREGADO, pedido.cliente_id=cliente reseñador;
--    detalle.variante.producto_id=resena.producto_id. Invitados sin reseñas.
-- 4) Fidelización: sólo pedidos cliente_id NOT NULL, pago confirmado;
--    ventas_delta=+1 por pedido pagado, sin importar cantidad de productos; acreditación única por pedido;
--    semestre calendario segun pagado_en en America/Tijuana; una recompensa de 10% al llegar a 10 pedidos pagados distintos por semestre.
-- 5) No asociar nunca compras de invitados a clientes de forma retroactiva.
-- 6) Cancelación sólo pedido completo, nunca entregado; sólo roles PROPIETARIO/ADMIN;
--    revertir lealtad e inventario idempotentemente; no borrar historial de cupón usado.
-- 7) Transferencia LOCAL: usuario de rol VENDEDOR verifica el abono real antes
--    de aprobar el pago; verificar no nulo verificado_por_usuario_id cuando apruebe.
--    Igual en cancelaciones: autorizador no nulo y rol ADMIN/PROPIETARIO al aprobar.
--    Estas validaciones tocan FK y estado, así que viven en servicio transaccional.
-- 8) Un solo cupon por pedido, sin acumulación de descuentos ni descuentos manuales;
--    cupones reservados en checkout, canjeados al pago y revertidos cuando proceda.
-- 9) Validar webhooks, estados finales de pago y pagos tardíos en CONCILIACION.
-- 10) No emitir ni aplicar CFDI en esta etapa; confirmar alcance fiscal pendiente.
-- 11) Semestres fijos no solapados: [01-ene,01-jul) y [01-jul,01-ene siguiente).
-- 12) Producto_imagenes.variante_id, si existe, debe ser variante de producto_id.
-- 13) Producto SKU o inventario importado debe validar filas y registrar errores.
-- 14) Si cancela la compra generadora con cupón ya consumido, registrar incidencia;
--     no cambiar retroactivamente descuento de otro pedido. Política por aprobar.
-- 15) Totales de pedido y descuentos de lineas se guardan como snapshot historico y deben conciliar.
