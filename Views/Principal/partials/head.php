<!doctype html>
<html lang="es-MX">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#ffffff"><meta name="description" content="SHOCK 88 — Streetwear para quienes marcan su propio ritmo.">
  <title><?= htmlspecialchars($pageTitle ?? 'SHOCK 88 — Streetwear sin reglas', ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700;800;900&family=DM+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<?= htmlspecialchars($principalAssets, ENT_QUOTES, 'UTF-8') ?>/styles.css">
  <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js" defer></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js" defer></script>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/ScrollTrigger.min.js" defer></script>
  <?php if (empty($detailView)): ?>
  <script src="<?= htmlspecialchars($principalAssets, ENT_QUOTES, 'UTF-8') ?>/app.js" defer></script>
  <?php endif; ?>
  <?php if (!empty($detailView)): ?>
  <link rel="stylesheet" href="<?= htmlspecialchars($principalAssets, ENT_QUOTES, 'UTF-8') ?>/producto.css">
  <script src="<?= htmlspecialchars($principalAssets, ENT_QUOTES, 'UTF-8') ?>/producto.js" defer></script>
  <?php endif; ?>
  <script>window.SHOCK88_BASE_URL = <?= json_encode(rtrim((string) BASE_URL, '/'), JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT) ?>;</script>
</head>
<body>

