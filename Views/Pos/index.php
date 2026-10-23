<?php
$base = rtrim(BASE_URL, '/') . '/';
$assetBase = $base . 'Assets/Pos/';
$h = static fn($value): string => htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
$json = json_encode($datosPos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
if ($json === false) { $json = '{}'; }
?>
<!doctype html>
<html lang="es-MX">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <meta name="theme-color" content="#111c22">
 <meta name="description" content="Prototipo del Punto de Venta Shock 88">
 <title>SHOCK 88 | Punto de Venta (Demo)</title>
 <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
 <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700;800;900&family=DM+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
 <link rel="stylesheet" href="<?= $h($assetBase) ?>pos.css?v=1">
 <script id="pos-data" type="application/json"><?= $json ?></script>
 <script src="<?= $h($assetBase) ?>pos.js?v=1" defer></script>
</head>
<body data-base="<?= $h($base) ?>">
<div class="app-shell">
 <div class="sidebar-cover" id="sidebar-cover" hidden></div>
 <aside class="sidebar" id="sidebar">
  <a class="brand" href="<?= $h($base) ?>pos"><img src="<?= $h($assetBase) ?>img/logo-shock-88.png" alt="Logo Shock 88"><div><strong>SHOCK <em>88</em></strong><span>POINT OF SALE</span></div></a>
  <div class="sidebar-divider"></div><div class="side-label">ESPACIO DE VENTA</div>
  <nav class="sidebar-nav" aria-label="Navegación del POS">
   <a class="side-item active" href="<?= $h($base) ?>pos" aria-current="page"><i class="fa-solid fa-cash-register"></i><span>Nueva venta</span><i class="fa-solid fa-angle-right side-arrow"></i></a>
   <button type="button" class="side-item" data-modal="history"><i class="fa-solid fa-receipt"></i><span>Ventas recientes</span></button>
   <button type="button" class="side-item" data-modal="cashbox"><i class="fa-solid fa-wallet"></i><span>Caja y movimientos</span></button>
  </nav>
  <div class="side-label side-label-secondary">ACCESOS RÁPIDOS</div>
  <nav class="sidebar-nav"><a class="side-item" href="<?= $h($base) ?>admin"><i class="fa-solid fa-chart-pie"></i><span>Administrador</span></a><a class="side-item" href="<?= $h($base) ?>principal"><i class="fa-solid fa-store"></i><span>Tienda pública</span></a><a class="side-item" href="<?= $h($base) ?>acceso"><i class="fa-solid fa-arrow-right-from-bracket"></i><span>Salir (demo)</span></a></nav>
  <div class="sidebar-bottom"><div class="counter-badge"><i class="fa-solid fa-circle-check"></i> CAJA DEMO ABIERTA</div><div class="cashier-profile"><div class="profile-avatar">V</div><div><strong>Vendedor de muestra</strong><span>Mostrador · Tijuana</span></div><i class="fa-solid fa-ellipsis-vertical"></i></div></div>
 </aside>
 <div class="content-column">
  <header class="topbar">
   <div class="topbar-left"><button class="icon-btn hamburger" id="toggle-menu" type="button" aria-label="Abrir menú"><i class="fa-solid fa-bars"></i></button><span class="breadcrumb">SHOCK 88 <i class="fa-solid fa-chevron-right"></i> <b>Punto de Venta</b></span></div>
   <div class="topbar-right"><span class="top-pill"><i class="fa-solid fa-location-dot"></i> TIJUANA · SUCURSAL DEMO</span><span class="top-date" id="top-date">23 OCT 2026</span><span class="live-pill"><b></b> MODO DEMO</span><button type="button" id="help-btn" class="icon-btn" aria-label="Ayuda"><i class="fa-regular fa-circle-question"></i></button></div>
  </header>
  <main class="workspace">
   <div class="page-title"><div><div class="eyebrow"><span></span> SISTEMA DE VENTAS / SHOCK 88</div><h1>NUEVA <em>VENTA.</em></h1><p>Encuentra el producto, vincula al cliente y prepara el cobro desde un solo lugar.</p></div><div class="folio-tag"><span>FOLIO TEMPORAL</span><strong id="sale-folio">S88-DEM-0001</strong></div></div>
   <div class="demo-message"><i class="fa-solid fa-circle-info"></i><span><b>Vista de demostración.</b> Sin base de datos, sin cobros reales y sin cambios de inventario. Los productos, clientes y beneficios son simulados.</span></div>
   <div class="pos-layout">
    <section class="catalog-panel" aria-labelledby="catalog-title">
     <div class="panel-heading"><div><span class="heading-label">01 / CATÁLOGO</span><h2 id="catalog-title">BUSCAR PRODUCTOS</h2></div><span class="inventory-note"><i class="fa-solid fa-boxes-stacked"></i> Stock de ejemplo</span></div>
     <div class="search-row"><label class="product-search"><i class="fa-solid fa-magnifying-glass"></i><input type="search" id="product-search" placeholder="Buscar prenda, SKU o talla..." autocomplete="off" aria-label="Buscar prendas por nombre o SKU"><kbd>Ctrl K</kbd></label><button id="barcode-focus" class="scan-button" type="button" title="Buscar mediante lector de código de barras conectado como teclado"><i class="fa-solid fa-barcode"></i><span>SKU</span></button></div>
     <div class="category-list" id="category-list" aria-label="Filtrar por categoría"><button class="category-chip active" data-category="Todas">TODOS</button><button class="category-chip" data-category="Playeras">PLAYERAS</button><button class="category-chip" data-category="Sudaderas">SUDADERAS</button><button class="category-chip" data-category="Pantalones">PANTALONES</button></div>
     <div class="catalog-count"><strong id="catalog-results">8 PRODUCTOS</strong><span>Selecciona una talla para agregar al ticket</span></div>
     <div class="product-grid" id="product-grid" aria-live="polite"></div>
     <div class="catalog-footer"><i class="fa-solid fa-bolt"></i> Consejo: el lector de códigos puede escribir directamente en el buscador del POS.</div>
    </section>
    <section class="ticket-panel" aria-labelledby="ticket-heading">
      <div class="ticket-head"><div><span class="heading-label">02 / CHECKOUT</span><h2 id="ticket-heading">TICKET DE VENTA <span id="ticket-count">(0)</span></h2></div><button id="new-sale" class="ghost-action" type="button"><i class="fa-solid fa-rotate-left"></i> Nueva venta</button></div>
      <div class="customer-strip"><div class="customer-avatar" id="customer-avatar"><i class="fa-regular fa-user"></i></div><div class="customer-text"><strong id="customer-name">Público general</strong><span id="customer-detail">Venta sin cliente identificado</span></div><button id="choose-customer" type="button" class="customer-change"><i class="fa-solid fa-user-plus"></i> <span>Vincular</span></button></div>
      <div class="loyalty-box" id="loyalty-box" hidden><div class="loyalty-top"><span><i class="fa-solid fa-crown"></i> SHOCK REWARDS · 2026-S2</span><strong id="loyalty-count">7 / 10</strong></div><div class="loyalty-track"><span id="loyalty-progress"></span></div><small id="loyalty-detail">Le faltan 3 compras pagadas para su beneficio.</small></div>
      <div class="cart-heading"><span>PRODUCTO / VARIANTE</span><span>PRECIO</span><span>CANT.</span><span>IMPORTE</span></div>
      <div id="cart-list" class="cart-list"><div class="cart-placeholder"><span class="empty-circle"><i class="fa-solid fa-bag-shopping"></i></span><strong>EL TICKET ESTÁ VACÍO</strong><p>Selecciona una prenda del catálogo para iniciar.</p></div></div>
      <div class="ticket-checkout">
       <div class="coupon-area"><div class="coupon-title"><span><i class="fa-solid fa-ticket"></i> CUPÓN DE DESCUENTO</span><button type="button" id="discount-help" class="micro-link">Condiciones <i class="fa-solid fa-circle-info"></i></button></div><div class="coupon-input"><input id="coupon-code" type="text" placeholder="Ej. SHOCK10" autocomplete="off" maxlength="30" aria-label="Código de descuento"><button id="apply-coupon" type="button">APLICAR</button></div><div class="coupon-feedback" id="coupon-feedback" role="status" aria-live="polite"></div></div>
       <div class="total-lines"><div><span>Subtotal</span><strong id="subtotal">$0.00</strong></div><div class="discount-line"><span>Descuento <span id="discount-label"></span></span><strong id="discount">−$0.00</strong></div><div class="total-grand"><span>TOTAL A COBRAR <small>MXN</small></span><strong id="grand-total">$0.00</strong></div></div>
       <div class="payment-area"><div class="payment-heading"><strong>03 / MÉTODO DE PAGO</strong><span>Selecciona uno</span></div><div class="payment-methods" role="group" aria-label="Método de pago"><button class="payment-btn active" type="button" data-payment="EFECTIVO" aria-pressed="true"><i class="fa-solid fa-money-bill-wave"></i> Efectivo</button><button class="payment-btn" type="button" data-payment="TARJETA" aria-pressed="false"><i class="fa-regular fa-credit-card"></i> Tarjeta</button><button class="payment-btn" type="button" data-payment="TRANSFERENCIA" aria-pressed="false"><i class="fa-solid fa-arrow-right-arrow-left"></i> Transferencia</button></div><div class="cash-payment" id="cash-payment"><label for="cash-received">Efectivo recibido</label><div class="cash-input"><span>$</span><input id="cash-received" type="number" inputmode="decimal" min="0" step="0.01" placeholder="0.00"></div><div class="change-due"><span>Cambio a entregar</span><strong id="change-due">$0.00</strong></div></div><p class="method-message" id="payment-message" hidden></p></div>
       <button type="button" id="checkout" class="checkout-button" disabled><i class="fa-solid fa-lock"></i><span>SIMULAR COBRO</span><strong id="checkout-total">$0.00</strong><i class="fa-solid fa-arrow-right"></i></button><div class="security-foot"><i class="fa-solid fa-shield-halved"></i> Esta simulación nunca cobra dinero ni genera pedidos reales.</div>
      </div>
    </section>
   </div>
  </main>
  <footer class="pos-footer"><span>SHOCK 88 · DEMOSTRACIÓN POS</span><span>TECNOLOGÍA PARA VENDER CON ACTITUD <b>⚡</b></span></footer>
 </div>
</div>
<div class="overlay" id="overlay" hidden></div>
<div class="modal" id="customer-modal" role="dialog" aria-modal="true" aria-labelledby="customer-modal-title" hidden><div class="modal-head"><div><span class="heading-label">VINCULAR CLIENTE</span><h2 id="customer-modal-title">¿QUIÉN ESTÁ COMPRANDO?</h2></div><button class="modal-close" type="button" aria-label="Cerrar"><i class="fa-solid fa-xmark"></i></button></div><div class="modal-body"><label class="modal-search"><i class="fa-solid fa-magnifying-glass"></i><input id="customer-search" placeholder="Buscar por nombre, teléfono o correo..." autocomplete="off"></label><div class="modal-list" id="customer-results"></div><button id="guest-customer" class="wide-ghost" type="button"><i class="fa-solid fa-user-slash"></i> CONTINUAR COMO PÚBLICO GENERAL</button><div class="modal-divider">¿AÚN NO ES CLIENTE?</div><button class="new-client-button" id="new-client" type="button"><i class="fa-solid fa-user-plus"></i> Registro rápido de cliente (demo) <i class="fa-solid fa-arrow-right"></i></button><form id="new-client-form" hidden><div class="form-grid"><label>Nombre completo <input id="client-new-name" name="nombre" required minlength="3" maxlength="150" placeholder="Nombre y apellidos"></label><label>Teléfono <input name="telefono" maxlength="30" placeholder="664 000 0000"></label><label class="span-2">Correo electrónico <input name="email" type="email" placeholder="cliente@correo.com"></label></div><button class="action-mint" type="submit">GUARDAR CLIENTE DE EJEMPLO</button></form></div></div>
<div class="modal" id="sale-modal" role="dialog" aria-modal="true" aria-labelledby="sale-modal-title" hidden><div class="modal-head"><div><span class="heading-label">COMPROBANTE DE DEMOSTRACIÓN</span><h2 id="sale-modal-title">VENTA SIMULADA</h2></div><button class="modal-close" type="button" aria-label="Cerrar"><i class="fa-solid fa-xmark"></i></button></div><div class="modal-body"><div class="success-icon"><i class="fa-solid fa-check"></i></div><p class="success-intro">Así se vería el resultado al finalizar una operación en caja.</p><div class="receipt-card"><div class="receipt-top"><b>SHOCK 88</b><small>SIMULACIÓN · SIN VALIDEZ FISCAL</small></div><div id="receipt-lines"></div></div><div class="success-note"><i class="fa-solid fa-triangle-exclamation"></i> No se descontó inventario, no se utilizó ningún cupón y no se registró un pago.</div><button id="start-next-sale" class="action-mint" type="button">INICIAR SIGUIENTE VENTA <i class="fa-solid fa-arrow-right"></i></button></div></div>
<div class="modal small-modal" id="info-modal" role="dialog" aria-modal="true" aria-labelledby="info-modal-title" hidden><div class="modal-head"><div><span class="heading-label">SHOCK 88 / POS</span><h2 id="info-modal-title">INFORMACIÓN</h2></div><button class="modal-close" type="button" aria-label="Cerrar"><i class="fa-solid fa-xmark"></i></button></div><div class="modal-body" id="info-modal-body"></div></div>
<div class="toast" id="toast" role="status" aria-live="polite"></div>
</body>
</html>
