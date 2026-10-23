<?php
/**
 * SHOCK 88 - Puerta de entrada visual para personal interno.
 * IMPORTANTE: Esto es SOLO un prototipo. No autentica ni autoriza usuarios.
 */
class Acceso extends Controller
{
    public function index()
    {
        require __DIR__ . '/../Views/Acceso/index.php';
    }
}
