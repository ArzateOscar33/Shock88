<?php
/** Datos ilustrativos compatibles con el catálogo previo del Home; SIN consultas SQL. */
$archivoCatalogo = __DIR__ . '/catalogo_demo.php';
$catalogo = is_file($archivoCatalogo) ? require $archivoCatalogo : [];
if (!is_array($catalogo) || !$catalogo) {
    $catalogo = [
       1 => ['nombre'=>'Playera Essential Black','categoria'=>'Playeras','precio'=>449,'imagen'=>''],
       2 => ['nombre'=>'Hoodie Shadow Oversize','categoria'=>'Sudaderas','precio'=>899,'imagen'=>''],
       3 => ['nombre'=>'Cargo Street Utility','categoria'=>'Pantalones','precio'=>799,'imagen'=>''],
       4 => ['nombre'=>'Playera Urban Core','categoria'=>'Playeras','precio'=>499,'imagen'=>''],
       5 => ['nombre'=>'Sudadera Heavyweight','categoria'=>'Sudaderas','precio'=>949,'imagen'=>''],
       6 => ['nombre'=>'Playera Basic Signature','categoria'=>'Playeras','precio'=>399,'imagen'=>''],
       7 => ['nombre'=>'Pantalón Relaxed Fit','categoria'=>'Pantalones','precio'=>749,'imagen'=>''],
       8 => ['nombre'=>'Crewneck Street Archive','categoria'=>'Sudaderas','precio'=>829,'imagen'=>'']
    ];
}
$productos = [];
foreach ($catalogo as $id => $p) {
    $categoria = (string)($p['categoria'] ?? 'Playeras');
    $prefijo = $categoria === 'Sudaderas' ? 'SUD' : ($categoria === 'Pantalones' ? 'PAN' : 'PLY');
    $colores = ['Negro','Blanco','Gris','Negro','Verde','Blanco','Negro','Gris'];
    $sizes = ['S','M','L','XL'];
    $variantes = [];
    foreach ($sizes as $indice => $talla) {
        $variantes[] = [
            'id' => (int)$id * 100 + $indice + 1, // ÚNICAMENTE un ID de muestra, no una PK real
            'sku' => sprintf('S88-%s-%03d-%s', $prefijo, (int)$id, $talla),
            'talla' => $talla,
            'color' => $colores[((int)$id - 1) % count($colores)],
            'precio' => (float)($p['precio'] ?? 0),
            'stock' => max(1, 9 - (($indice + (int)$id) % 7)),
        ];
    }
    $productos[] = [
       'id' => (int)$id, 'nombre'=>(string)($p['nombre'] ?? ''),
       'categoria'=>$categoria, 'imagen'=>(string)($p['imagen'] ?? ''),
       'variantes'=>$variantes
    ];
}
return [
  'productos'=>$productos,
  'clientes'=>[
    ['id'=>101,'nombre'=>'Carlos Ramírez','telefono'=>'664 124 8801','email'=>'carlos.demo@example.com','compras'=>7,'recompensa'=>false,'tipo'=>'REGULAR'],
    ['id'=>102,'nombre'=>'Andrea López','telefono'=>'664 370 8872','email'=>'andrea.demo@example.com','compras'=>10,'recompensa'=>true,'tipo'=>'VIP'],
    ['id'=>103,'nombre'=>'Luis Mendoza','telefono'=>'664 590 2030','email'=>'luis.demo@example.com','compras'=>3,'recompensa'=>false,'tipo'=>'REGULAR'],
    ['id'=>104,'nombre'=>'Mario Torres','telefono'=>'664 217 4401','email'=>'mario.demo@example.com','compras'=>1,'recompensa'=>false,'tipo'=>'REGULAR']
  ],
  'cupones'=>[
    ['codigo'=>'SHOCK10','clase'=>'PUBLICO','porcentaje'=>10,'minimo'=>500,'soloCliente'=>false],
    ['codigo'=>'VIP15','clase'=>'VIP','porcentaje'=>15,'minimo'=>1000,'soloCliente'=>true],
    ['codigo'=>'REWARDS10','clase'=>'LEALTAD','porcentaje'=>10,'minimo'=>0,'soloCliente'=>true]
  ],
];
