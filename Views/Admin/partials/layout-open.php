<?php
$base = rtrim(BASE_URL, '/') . '/';
$assetBase = $base . 'Assets/Admin/';
$h = static function ($valor): string { return htmlspecialchars((string) $valor, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); };
$title = isset($modulo) ? $modulo['title'] : ($seccionActiva === 'reportes' ? 'Reportes' : 'Dashboard');
$allNav = $datos['navigation'] ?? [];
?>
<!doctype html>
<html lang="es-MX">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width, initial-scale=1">
 <meta name="theme-color" content="#10171c">
 <title><?= $h($title) ?> · Panel SHOCK 88</title>
 <link rel="preconnect" href="https://fonts.googleapis.com">
 <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
 <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700;800;900&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
 <link rel="stylesheet" href="<?= $h($assetBase) ?>admin.css?v=1">
 <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js" defer></script>
 <script src="<?= $h($assetBase) ?>admin.js?v=1" defer></script>
</head>
<body data-page="<?= $h($seccionActiva) ?>" data-base="<?= $h($base) ?>">
<div class="admin-shell">
<div class="sidebar-backdrop" id="sidebar-backdrop" hidden></div>
<aside class="sidebar" id="sidebar" aria-label="Navegación administrativa">
 <a class="sidebar-brand" href="<?= $h($base) ?>admin">
  <img src="<?= $h($assetBase) ?>img/logo-shock-88.png" alt="Shock 88" onerror="this.style.display='none'">
  <span><strong>SHOCK <b>88</b></strong><small>CONTROL CENTER</small></span>
 </a>
 <div class="sidebar-separator"></div>
 <div class="sidebar-scroll">
 <?php foreach ($allNav as $grupo): ?>
  <?php $isOpen = false; foreach ($grupo['items'] as $item) { if ($item['slug'] === $seccionActiva) $isOpen = true; } ?>
  <div class="nav-section">
   <button class="nav-group-title" type="button" aria-expanded="<?= $isOpen ? 'true' : 'false' ?>"><span><?= $h($grupo['group']) ?></span><i class="fa-solid fa-chevron-down"></i></button>
   <div class="nav-items" <?= $isOpen ? '' : 'hidden' ?>>
    <?php foreach ($grupo['items'] as $item): ?>
      <?php $href = $item['slug']==='dashboard' ? $base.'admin' : ($item['slug']==='reportes' ? $base.'admin/reportes' : $base.'admin/catalogo?modulo='.rawurlencode($item['slug'])); ?>
      <a class="nav-link <?= $item['slug'] === $seccionActiva ? 'active' : '' ?>" <?= $item['slug'] === $seccionActiva ? 'aria-current="page"' : '' ?> href="<?= $h($href) ?>"><i class="fa-solid <?= $h($item['icon']) ?>"></i><span><?= $h($item['name']) ?></span><?php if ($item['slug'] === $seccionActiva): ?><i class="fa-solid fa-chevron-right nav-tail"></i><?php endif; ?></a>
    <?php endforeach; ?>
   </div>
  </div>
 <?php endforeach; ?>
 </div>
 <div class="sidebar-bottom"><span class="sidebar-online-dot"></span><div><strong>SISTEMA DEMO</strong><small>Sin conexión a base de datos</small></div></div>
</aside>
<div class="main-column">
 <header class="topbar">
  <div class="topbar-left"><button class="top-icon" id="sidebar-toggle" type="button" aria-label="Abrir menú"><i class="fa-solid fa-bars"></i></button><span class="topbar-crumb">SHOCK 88 <i class="fa-solid fa-chevron-right"></i> <strong><?= $h($title) ?></strong></span></div>
  <div class="topbar-right"><span class="demo-pill"><span></span> MODO PROTOTIPO</span><button class="top-icon" id="notification-toggle" type="button" aria-label="Notificaciones de muestra"><i class="fa-regular fa-bell"></i><b class="notification-dot"></b></button><span class="topbar-user"><span class="avatar">A</span><span class="user-meta"><strong>Administrador</strong><small>Vista de muestra</small></span></span></div>
 </header>
 <main class="admin-main">
