<?php
// 🟢 Cabeceras CORS (necesarias para Flutter Web)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

$database = new Database();
$db = $database->getConnection();

// 🟠 Verificar conexión a la base de datos
if ($db === null) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error de conexión a la base de datos. Verifica que XAMPP esté ejecutándose y que la base de datos 'proyecto_crud' exista."
    ]);
    exit();
}

// 🟢 Consultar categorías
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
          GROUP BY c.id
          ORDER BY c.nombre ASC";

$stmt = $db->prepare($query);
$stmt->execute();

$num = $stmt->rowCount();

if ($num > 0) {
    $categorias_arr = [
        "success" => true,
        "data" => []
    ];

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $categorias_arr["data"][] = [
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
    }

    http_response_code(200);
    echo json_encode($categorias_arr);
} else {
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => [],
        "message" => "No se encontraron categorías."
    ]);
}
?>