# SHOCK 88 — Home / Demo visual V1

Prototipo responsive de la página principal, **sin PHP, base de datos, pagos reales ni persistencia**.

## Iniciar

Desde la carpeta `shock88-home`, ejecutar:

```bash
python3 -m http.server 8000
```

Abrir `http://localhost:8000` en el navegador. También puedes colocar esta carpeta en `htdocs` de XAMPP y entrar por el servidor local.

## Archivos

- `index.html` — Home, menú, secciones, hero, drawer y modal.
- `assets/styles.css` — diseño, colores, animaciones CSS y responsive.
- `assets/app.js` — arreglo de productos demo, búsqueda, filtros, carrito lateral, sonidos Web Audio, animaciones GSAP.
- `assets/img/logo-shock-88.png` — logo original proporcionado. Se conserva sin modificar; la cabecera utiliza una versión tipográfica compacta.
- `assets/video/hero-shock88.mp4` — **agrega tú el video aquí**, idealmente 8–15 segundos, H.264 MP4, horizontal y sin audio, para el hero. Si no existe, queda la imagen de respaldo.

## Nota sobre los recursos

Las fotografías son referencias **temporales de Unsplash**, se cargan desde Internet y pueden no representar exactamente los productos. Sustituir por imágenes autorizadas de las prendas reales antes de presentarlo como catálogo final. Las fuentes, iconos y GSAP se descargan de CDNs públicos; se requiere conexión a Internet para verlos con su aspecto definitivo.

## Demo del sonido

Los sonidos están **desactivados inicialmente**. En escritorio pulsa el icono de volumen en el header; en tablet entra al menú móvil. Agregar una prenda hace un doble clic sintetizado similar a la direccional; finalizar una compra simula un motor acelerando. Ambos se generan mediante Web Audio API, sin archivos MP3 externos. En navegadores se necesita una interacción del usuario para habilitar audio.

## Advertencias

- Los precios, descuentos y nombres son ilustrativos.
- El login no autentica; no se almacenan datos personales.
- El botón de checkout solo reproduce el efecto y muestra una notificación; **no cobra ni registra un pedido**.
- Links de redes están como marcadores de posición.
- La paleta es blanca predominante, contrastes negros y verde menta/azul del logo; cinta amarilla de promoción.
- Para integración MVC posterior, separar componentes del Home en vistas y trasladar recursos a la carpeta `public` existente.
