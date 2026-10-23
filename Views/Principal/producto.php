<?php
if (!defined('BASE_URL')) throw new RuntimeException('Se requiere BASE_URL');
$principalUrl = rtrim((string) BASE_URL, '/') . '/principal';
$principalAssets = rtrim((string) BASE_URL, '/') . '/Assets/Principal';
$pageTitle = $producto['nombre'] . ' | SHOCK 88';
$detailView = true;
$e = static fn ($v) => htmlspecialchars((string) $v, ENT_QUOTES, 'UTF-8');
$mx = static fn ($v) => '$' . number_format((float)$v, 0) . ' MXN';
$recomendados = array_values(array_filter($catalogo, static fn ($p) => $p['id'] !== $producto['id']));
$recomendados = array_slice($recomendados, 0, 7);
?>
<?php require __DIR__ . '/partials/head.php'; ?>
<?php require __DIR__ . '/partials/header.php'; ?>
<main class="detail-main">
  <div class="container pd-breadcrumb"><a href="<?= $e($principalUrl) ?>">INICIO</a><span>/</span><a href="<?= $e($principalUrl) ?>#novedades">HOMBRE</a><span>/</span><span><?= $e($producto['nombre']) ?></span></div>
  <section class="container pd-layout" aria-labelledby="pd-title">
    <div class="pd-gallery">
      <div class="pd-main-photo"><img id="pd-main-image" src="<?= $e($producto['imagenes'][0]) ?>" alt="<?= $e($producto['nombre']) ?> — imagen principal" /><span class="pd-photo-tag">SHOCK 88 / DROP 01</span><button class="pd-expand" id="pd-zoom" aria-label="Ampliar fotografía"><i data-lucide="expand"></i></button></div>
      <div class="pd-thumbnails" aria-label="Galería de cuatro imágenes">
      <?php foreach ($producto['imagenes'] as $idx => $url): ?>
        <button class="pd-thumb <?= $idx === 0 ? 'selected' : '' ?>" data-image="<?= $e($url) ?>" data-index="<?= $idx ?>" aria-label="Mostrar imagen <?= $idx+1 ?>" aria-pressed="<?= $idx === 0 ? 'true' : 'false' ?>"><img src="<?= $e($url) ?>" alt="Referencia visual <?= $idx+1 ?>" loading="<?= $idx === 0 ? 'eager' : 'lazy' ?>"></button>
      <?php endforeach; ?>
      </div>
      <div class="pd-gallery-nav"><button id="pd-prev" aria-label="Imagen anterior"><i data-lucide="arrow-left"></i></button><span id="pd-gallery-counter">01 / 04</span><button id="pd-next" aria-label="Imagen siguiente"><i data-lucide="arrow-right"></i></button></div>
    </div>
    <div class="pd-info">
      <div class="pd-eyebrow">SHOCK 88 <span>/</span> <?= $e(strtoupper($producto['categoria'])) ?> <?php if ($producto['etiqueta']): ?><b><?= $e($producto['etiqueta']) ?></b><?php endif; ?></div>
      <h1 id="pd-title"><?= $e($producto['nombre']) ?></h1>
      <p class="pd-tagline">STREETWEAR / TU ESTILO, TUS REGLAS.</p>
      <div class="pd-price"><strong><?= $e($mx($producto['precio'])) ?></strong><?php if ($producto['precioAnterior']): ?><del><?= $e($mx($producto['precioAnterior'])) ?></del><span>OFERTA</span><?php endif; ?></div>
      <div class="pd-divider"></div>
      <div class="pd-color"><span>COLOR</span><strong><?= $e($producto['color']) ?></strong></div>
      <div class="pd-size-head"><label for="pd-size">SELECCIONA TU TALLA</label><button id="pd-size-guide">GUÍA DE TALLAS <i data-lucide="ruler"></i></button></div>
      <div class="pd-sizes" id="pd-size" role="group" aria-label="Tallas disponibles">
       <?php foreach ($producto['tallas'] as $size): ?><button type="button" class="pd-size" data-size="<?= $e($size) ?>" aria-pressed="false"><?= $e($size) ?></button><?php endforeach; ?>
      </div>
      <p class="pd-size-error" id="pd-size-error" aria-live="polite"></p>
      <div class="pd-quantity-row"><label for="pd-quantity">CANTIDAD</label><div class="pd-quantity"><button type="button" id="pd-minus" aria-label="Reducir cantidad">−</button><input id="pd-quantity" type="number" min="1" max="10" value="1" inputmode="numeric" aria-label="Cantidad"><button type="button" id="pd-plus" aria-label="Aumentar cantidad">+</button></div></div>
      <button class="pd-add btn btn-black" id="pd-add-cart">AGREGAR AL CARRITO <i data-lucide="shopping-bag"></i></button>
      <p class="pd-smallprint"><i data-lucide="truck"></i> Compra simulada · sin cobros reales</p>
      <div class="pd-details"><details open><summary>DESCRIPCIÓN <i data-lucide="plus"></i></summary><p><?= $e($producto['descripcion']) ?></p></details><details><summary>ENVÍOS Y DEVOLUCIONES <i data-lucide="plus"></i></summary><p>Información demostrativa. Las políticas se definirán antes del lanzamiento.</p></details><details><summary>CUIDADOS <i data-lucide="plus"></i></summary><p>Revisa la etiqueta de cuidado de cada prenda cuando se incorporen los productos reales.</p></details></div>
    </div>
  </section>
  <section class="pd-recommend" aria-labelledby="pd-rec-title"><div class="container"><div class="pd-rec-heading"><div><p class="pd-rec-kicker">/ COMPLETA TU FIT</p><h2 id="pd-rec-title">TAMBIÉN TE <em>PUEDE GUSTAR.</em></h2></div><div class="pd-rec-controls"><button id="rec-prev" aria-label="Anterior recomendación"><i data-lucide="arrow-left"></i></button><button id="rec-next" aria-label="Siguiente recomendación"><i data-lucide="arrow-right"></i></button></div></div>
  <div class="pd-rec-track" id="pd-rec-track" tabindex="0" aria-label="Productos recomendados">
  <?php foreach ($recomendados as $r): ?><a class="pd-rec-card" href="<?= $e($principalUrl . '/producto?id=' . $r['id']) ?>"><div class="pd-rec-photo"><img src="<?= $e($r['imagen']) ?>" alt="<?= $e($r['nombre']) ?>" loading="lazy"><?php if ($r['etiqueta']): ?><span><?= $e($r['etiqueta']) ?></span><?php endif; ?></div><small>SHOCK 88 / <?= $e($r['categoria']) ?></small><h3><?= $e($r['nombre']) ?></h3><strong><?= $e($mx($r['precio'])) ?></strong></a><?php endforeach; ?>
  </div><p class="pd-demo-note">Fotografías ilustrativas del catálogo demo; no corresponden a cuatro ángulos reales de una misma prenda.</p></div></section>
</main>
<script id="pd-data" type="application/json"><?= json_encode(['id'=>$producto['id'],'name'=>$producto['nombre'],'price'=>$producto['precio'],'image'=>$producto['imagen'],'images'=>$producto['imagenes']], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?></script>
<script id="pd-catalog" type="application/json"><?= json_encode(array_values(array_map(static fn ($p) => ['id'=>$p['id'],'name'=>$p['nombre'],'price'=>$p['precio'],'image'=>$p['imagen']], $catalogo)), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?></script>
<div class="pd-zoom-modal" id="pd-zoom-modal" role="dialog" aria-modal="true" aria-label="Imagen ampliada" hidden><button id="pd-zoom-close" aria-label="Cerrar fotografía">✕</button><img id="pd-zoom-img" alt="Fotografía ampliada"></div>
<?php require __DIR__ . '/partials/footer.php'; ?>
<?php require __DIR__ . '/partials/overlays.php'; ?>
</body></html>
