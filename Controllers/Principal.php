<?php
/** Demo público Shock 88; no se conecta a BD. */
class Principal extends Controller
{
    public function index()
    {
        require __DIR__ . '/../Views/Principal/index.php';
    }

    public function producto()
    {
        $catalogo = require __DIR__ . '/../Data/catalogo_demo.php';
        $id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
        if (!$id || !isset($catalogo[$id])) {
            http_response_code(404);
            echo '<!doctype html><html lang="es"><meta charset="utf-8"><title>No encontrado</title><body style="font-family:Arial;padding:4rem"><h1>Producto no encontrado</h1><a href="' . htmlspecialchars(rtrim(BASE_URL, '/') . '/principal', ENT_QUOTES, 'UTF-8') . '">Volver a la tienda</a></body></html>';
            return;
        }
        $producto = $catalogo[$id];
        require __DIR__ . '/../Views/Principal/producto.php';
    }
}
