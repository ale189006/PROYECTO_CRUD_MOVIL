<?php
// 🟢 Cabeceras CORS — siempre al inicio del archivo
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight requests (muy importante para Flutter Web)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

$database = new Database();
$db = $database->getConnection();

$id = isset($_GET['id']) ? $_GET['id'] : die();

$query = "SELECT 
            c.id,
            c.nombre,
            c.descripcion,
            c.icono,
            c.color,
            c.activo,
            c.fecha_creacion,
            c.fecha_actualizacion,
            COUNT(p.id) as total_productos
          FROM categorias c
          LEFT JOIN productos p ON c.id = p.categoria_id
          WHERE c.id = :id
          GROUP BY c.id";

$stmt = $db->prepare($query);
$stmt->bindParam(":id", $id);
$stmt->execute();

$num = $stmt->rowCount();

if ($num > 0) {
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $categoria_item = [
        "id" => $row['id'],
        "nombre" => $row['nombre'],
        "descripcion" => $row['descripcion'],
        "icono" => $row['icono'],
        "color" => $row['color'],
        "activo" => (bool)$row['activo'],
        "total_productos" => (int)$row['total_productos'],
        "fecha_creacion" => $row['fecha_creacion'],
        "fecha_actualizacion" => $row['fecha_actualizacion']
    ];

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => $categoria_item
    ]);
} else {
    http_response_code(404);
    echo json_encode([
        "success" => false,
        "message" => "Categoría no encontrada."
    ]);
}
?>