<?php
/** Panel administrativo DEMO: sin autenticación ni consultas SQL. No publicar así en producción. */
class Admin extends Controller
{
    private function datos(): array
    {
        $json = file_get_contents(__DIR__ . '/../Data/admin_demo.json');
        $datos = json_decode($json, true);
        if (!is_array($datos)) {
            throw new RuntimeException('No se pudo cargar Data/admin_demo.json');
        }
        return $datos;
    }

    public function index($parametro = '')
    {
        $datos = $this->datos();
        $seccionActiva = 'dashboard';
        require __DIR__ . '/../Views/Admin/index.php';
    }

    public function catalogo($parametro = '')
    {
        $datos = $this->datos();
        $seccionActiva = isset($_GET['modulo']) && is_string($_GET['modulo']) ? $_GET['modulo'] : 'productos';
        if (!isset($datos['modules'][$seccionActiva])) {
            http_response_code(404);
            require __DIR__ . '/../Views/Admin/no-encontrado.php';
            return;
        }
        $modulo = $datos['modules'][$seccionActiva];
        require __DIR__ . '/../Views/Admin/catalogo.php';
    }

    public function reportes($parametro = '')
    {
        $datos = $this->datos();
        $seccionActiva = 'reportes';
        require __DIR__ . '/../Views/Admin/reportes.php';
    }
}
