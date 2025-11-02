<?php
// 🟢 Cabeceras CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight (importantísimo para Flutter Web)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

$database = new Database();
$db = $database->getConnection();

// 🟢 Validar parámetro ID
if (!isset($_GET['id']) || empty($_GET['id'])) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "ID de producto no proporcionado."
    ]);
    exit();
}

$id = $_GET['id'];

$query = "SELECT 
            p.id, p.nombre, p.descripcion, p.precio, p.stock, 
            p.imagen_url, p.sku, p.activo, p.fecha_creacion, p.fecha_actualizacion,
            c.id AS categoria_id, c.nombre AS categoria_nombre, 
            c.color AS categoria_color, c.icono AS categoria_icono
          FROM productos p
          INNER JOIN categorias c ON p.categoria_id = c.id
          WHERE p.id = :id
          LIMIT 1";

$stmt = $db->prepare($query);
$stmt->bindParam(":id", $id, PDO::PARAM_INT);
$stmt->execute();

// 🟢 Si existe el producto
if ($stmt->rowCount() > 0) {
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    $producto_item = [
        "id" => (int)$row['id'],
        "nombre" => $row['nombre'],
        "descripcion" => $row['descripcion'],
        "precio" => (float)$row['precio'],
        "stock" => (int)$row['stock'],
        "imagen_url" => $row['imagen_url'],
        "sku" => $row['sku'],
        "activo" => (bool)$row['activo'],
        "fecha_creacion" => $row['fecha_creacion'],
        "fecha_actualizacion" => $row['fecha_actualizacion'],
        "categoria" => [
            "id" => (int)$row['categoria_id'],
            "nombre" => $row['categoria_nombre'],
            "color" => $row['categoria_color'],
            "icono" => $row['categoria_icono']
        ]
    ];

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => $producto_item
    ]);
} else {
    http_response_code(404);
    echo json_encode([
        "success" => false,
        "message" => "Producto no encontrado."
    ]);
}
?>