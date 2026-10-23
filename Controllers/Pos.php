<?php
/** SHOCK 88 POS | Vista de demostración; no procesa transacciones. */
class Pos extends Controller
{
    public function index($parametro = '')
    {
        $archivo = __DIR__ . '/../Data/pos_demo.php';
        $datosPos = require $archivo;
        require __DIR__ . '/../Views/Pos/index.php';
    }
}
