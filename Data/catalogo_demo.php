<?php
/** Catálogo temporal. Las fotos son referencias Unsplash ya empleadas en el Home. */
$img = static fn (string $photo, int $w = 1200) => "https://images.unsplash.com/{$photo}?w={$w}&q=85&fit=crop";
$items = [
  [1,'Playera Essential Black','Playeras',449,null,'NUEVO','photo-1521572163474-6864f9cf17ab','Algodón suave, silueta urbana y un básico para todos los días.'],
  [2,'Hoodie Shadow Oversize','Sudaderas',899,null,'DROP 01','photo-1556821840-3a63f95609a7','Sudadera de inspiración streetwear con corte relajado.'],
  [3,'Cargo Street Utility','Pantalones',799,null,'NUEVO','photo-1473966968600-fa801b869a1a','Pantalón versátil con identidad urbana y ajuste cómodo.'],
  [4,'Playera Urban Core','Playeras',499,null,'','photo-1503342217505-b0a15ec3261c','Un básico de estética minimalista para combinar sin esfuerzo.'],
  [5,'Sudadera Heavyweight','Sudaderas',949,null,'NUEVO','photo-1578681994506-b8f463449011','Textura cómoda y una silueta que destaca.'],
  [6,'Playera Basic Signature','Playeras',399,499,'-20%','photo-1503341504253-dff4815485f1','Diseño versátil para un look de todos los días.'],
  [7,'Pantalón Relaxed Fit','Pantalones',749,null,'','photo-1511196044526-5cb3bcb7071b','Corte relajado para moverte con libertad.'],
  [8,'Crewneck Street Archive','Sudaderas',829,999,'OFERTA','photo-1434389677669-e08b4cac3105','Una capa con actitud, inspirada en el streetwear clásico.'],
];
$resultado = [];
foreach ($items as [$id,$nombre,$categoria,$precio,$precioAnterior,$etiqueta,$foto,$descripcion]) {
    // Por ahora se muestran cuatro REFERENCIAS visuales, no cuatro fotos verificadas de la misma prenda.
    $variantes = [$foto];
    foreach (['photo-1521572163474-6864f9cf17ab','photo-1503342217505-b0a15ec3261c','photo-1556821840-3a63f95609a7','photo-1578681994506-b8f463449011','photo-1473966968600-fa801b869a1a'] as $alternativa) {
        if (count($variantes) === 4) break;
        if ($alternativa !== $foto) $variantes[] = $alternativa;
    }
    $resultado[$id] = compact('id','nombre','categoria','precio','precioAnterior','etiqueta','descripcion') + [
        'imagen' => $img($foto),
        'imagenes' => array_map($img, $variantes),
        'tallas' => ['S','M','L','XL','XXL'],
        'color' => 'Negro / Streetwear',
    ];
}
return $resultado;
