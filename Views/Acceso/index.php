<?php
/**
 * Acceso para EMPLEADOS (Administración / POS).
 * No comparte formulario ni credenciales con el login de CLIENTES.
 * Sin conexión a base de datos y sin autenticación real.
 */
$baseUrl = rtrim((string) BASE_URL, '/') . '/';
$assetsUrl = $baseUrl . 'Assets/Acceso/';
$logoUrl = $baseUrl . 'Assets/Principal/img/logo-shock-88.png';
$esc = static fn (string $value): string => htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="es-MX">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#080b0b">
  <meta name="robots" content="noindex, nofollow">
  <meta name="description" content="Acceso interno a SHOCK 88: administración y punto de venta. Prototipo visual.">
  <title>Acceso interno | SHOCK 88</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700;800;900&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<?= $esc($assetsUrl) ?>acceso.css">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js" defer></script>
  <script src="<?= $esc($assetsUrl) ?>acceso.js" defer></script>
</head>
<body>
  <div class="background" aria-hidden="true">
    <img class="background-photo" src="<?= $esc($assetsUrl) ?>img/fondo-urbano.jpg" alt="">
    <div class="background-shade"></div>
    <div class="background-grid"></div>
  </div>

  <div class="page-frame">
    <header class="topbar">
      <a class="identity" href="<?= $esc($baseUrl) ?>principal" aria-label="Ir a la tienda Shock 88">
        <img src="<?= $esc($logoUrl) ?>" alt="Logo de Shock 88" width="66" height="66">
        <span class="identity-copy"><strong>SHOCK <b>88</b></strong><small>INTERNAL SYSTEM // EST. 2026</small></span>
      </a>
      <a class="store-link" href="<?= $esc($baseUrl) ?>principal">
        <span aria-hidden="true">←</span> VOLVER A LA TIENDA
      </a>
    </header>

    <main class="scene">
      <section class="editorial" aria-label="Mensaje de bienvenida">
        <div class="editorial-inner">
          <span class="eyebrow"><span class="eyebrow-line"></span> STAFF ONLY / 88</span>
          <h1>DETRÁS<br>DEL <span>DROP.</span></h1>
          <p>El estilo está en la calle.<br>El control está aquí.</p>
          <div class="editorial-bottom">
            <span class="square-icon" aria-hidden="true">✳</span>
            <span>GESTIÓN DE TIENDA<br>Y PUNTO DE VENTA</span>
          </div>
        </div>
      </section>

      <section class="auth-zone" aria-label="Acceso de personal">
        <div class="auth-card">
          <div class="card-line"><span class="live-indicator"><span></span> SISTEMA INTERNO</span><span>88 / ACCESS</span></div>

          <div id="form-stage">
            <div class="title-group">
              <span class="form-kicker">BIENVENIDO AL EQUIPO</span>
              <h2>INICIAR <em>SESIÓN.</em></h2>
              <p>Elige un entorno para visualizar el acceso correspondiente.</p>
            </div>

            <form id="staff-form" autocomplete="off">
              <fieldset class="role-fieldset">
                <legend>ENTORNO DE DEMOSTRACIÓN</legend>
                <div class="role-options" role="group" aria-label="Selecciona un entorno de demostración">
                  <label class="role-option">
                    <input type="radio" name="entorno" value="admin" checked>
                    <span class="role-box"><span class="role-icon" aria-hidden="true">▦</span><span><strong>ADMIN</strong><small>Administración</small></span></span>
                  </label>
                  <label class="role-option">
                    <input type="radio" name="entorno" value="pos">
                    <span class="role-box"><span class="role-icon" aria-hidden="true">▤</span><span><strong>VENTAS</strong><small>Punto de venta</small></span></span>
                  </label>
                </div>
              </fieldset>

              <div class="form-field">
                <label for="correo">CORREO INSTITUCIONAL</label>
                <div class="input-frame">
                  <svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>
                  <input id="correo" name="correo" type="email" placeholder="empleado@shock88.test" inputmode="email" autocapitalize="none" spellcheck="false" maxlength="120" required>
                </div>
              </div>

              <div class="form-field">
                <label for="contrasena">CONTRASEÑA</label>
                <div class="input-frame">
                  <svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>
                  <input id="contrasena" name="contrasena" type="password" placeholder="Usa una clave ficticia" minlength="4" maxlength="120" required>
                  <button class="password-toggle" id="password-toggle" type="button" aria-controls="contrasena" aria-label="Mostrar contraseña">MOSTRAR</button>
                </div>
                <span class="caps-notice" id="caps-notice" hidden>Bloq Mayús está activado.</span>
              </div>

              <div class="form-utilities">
                <label class="remember"><input type="checkbox" id="recordar"><span>Recordarme <small>(demo)</small></span></label>
                <button type="button" class="forgot" id="forgot-btn">¿Olvidaste tu contraseña?</button>
              </div>

              <button type="submit" class="enter-btn">
                <span>ENTRAR AL SISTEMA</span>
                <span class="enter-arrow" aria-hidden="true">↗</span>
              </button>
            </form>

            <p class="disclaimer"><span aria-hidden="true">◈</span> DEMO VISUAL: no comprueba contraseñas ni concede permisos. Usa datos inventados.</p>
          </div>

          <div id="result-stage" class="result-stage" hidden aria-live="polite">
            <div class="result-symbol" aria-hidden="true">✓</div>
            <span class="form-kicker">SIMULACIÓN COMPLETADA</span>
            <h2>ENTORNO <em>LISTO.</em></h2>
            <p id="result-description">Prepararemos este entorno en la siguiente etapa.</p>
            <div class="destination" id="destination-name">ADMINISTRACIÓN</div>
            <p class="result-note">Esta pantalla no inicia una sesión real ni habilita el panel interno.</p>
            <button type="button" class="enter-btn" id="reset-btn"><span>VOLVER AL ACCESO</span><span class="enter-arrow" aria-hidden="true">↶</span></button>
          </div>
        </div>
        <div class="card-caption"><span>01 / 02 — INTERNAL ACCESS</span><span>SHOCK 88 // PRIVATE AREA</span></div>
      </section>
    </main>

    <footer class="page-footer"><span>© <?= date('Y') ?> SHOCK 88 · PROTOTIPO VISUAL</span><span>NO SIGAS LA CORRIENTE<span class="footer-bolt"> ⚡</span></span></footer>
  </div>
  <div class="toast" id="toast" role="status" aria-live="polite"></div>
</body>
</html>
