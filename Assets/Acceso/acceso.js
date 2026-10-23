/* SHOCK 88 - Acceso de personal - SOLO DEMO, sin envío ni validación real */
(() => {
  'use strict';
  const $ = (selector) => document.querySelector(selector);
  const form = $('#staff-form');
  const password = $('#contrasena');
  const email = $('#correo');
  const showPassword = $('#password-toggle');
  const capsNotice = $('#caps-notice');
  const toastElement = $('#toast');
  let timerId;

  function toast(message) {
    toastElement.textContent = message;
    toastElement.classList.add('is-visible');
    window.clearTimeout(timerId);
    timerId = window.setTimeout(() => toastElement.classList.remove('is-visible'), 3600);
  }

  showPassword.addEventListener('click', () => {
    const reveal = password.type === 'password';
    password.type = reveal ? 'text' : 'password';
    showPassword.textContent = reveal ? 'OCULTAR' : 'MOSTRAR';
    showPassword.setAttribute('aria-label', reveal ? 'Ocultar contraseña' : 'Mostrar contraseña');
  });

  password.addEventListener('keyup', (event) => {
    capsNotice.hidden = !event.getModifierState('CapsLock');
  });
  password.addEventListener('blur', () => { capsNotice.hidden = true; });

  $('#forgot-btn').addEventListener('click', () => {
    toast('Recuperación de contraseña no disponible en el demo. Se implementará con autenticación real.');
  });

  form.addEventListener('submit', (event) => {
    event.preventDefault(); // NUNCA enviamos ni almacenamos estas credenciales.
    if (!form.reportValidity()) return;
    const profile = form.elements.entorno.value;
    const details = profile === 'admin'
      ? { title: 'ADMINISTRACIÓN', text: 'La próxima fase de SHOCK 88 conectará aquí con el panel para gestionar productos, inventario y operaciones.' }
      : { title: 'PUNTO DE VENTA', text: 'La próxima fase de SHOCK 88 conectará aquí con el POS para registrar ventas y atender clientes.' };
    $('#destination-name').textContent = details.title;
    $('#result-description').textContent = details.text;
    password.value = '';
    email.value = '';
    $('#recordar').checked = false;
    $('#form-stage').hidden = true;
    $('#result-stage').hidden = false;
    $('#reset-btn').focus();
    if (window.gsap && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      window.gsap.fromTo('#result-stage', { opacity: 0, y: 18 }, { opacity: 1, y: 0, duration: .42, ease: 'power2.out' });
    }
  });

  $('#reset-btn').addEventListener('click', () => {
    $('#result-stage').hidden = true;
    $('#form-stage').hidden = false;
    form.reset();
    password.type = 'password';
    showPassword.textContent = 'MOSTRAR';
    showPassword.setAttribute('aria-label', 'Mostrar contraseña');
    email.focus();
  });

  if (window.gsap && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    window.gsap.from('.editorial-inner > *', { y: 24, opacity: 0, stagger: .11, duration: .7, ease: 'power2.out' });
    window.gsap.from('.auth-zone', { x: 32, opacity: 0, duration: .78, delay: .13, ease: 'power2.out' });
  }
})();
