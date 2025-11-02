<?php
// 🟢 Cabeceras CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight (crítico para Flutter Web)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

$database = new Database();
$db = $database->getConnection();

// 🟢 Verificar conexión
if ($db === null) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error de conexión a la base de datos. Verifica que XAMPP esté ejecutándose y que la base de datos 'proyecto_crud' exista."
    ]);
    exit();
}

// 🟢 Filtrado por categoría (opcional)
$categoria_id = isset($_GET['categoria_id']) ? $_GET['categoria_id'] : null;

$query = "SELECT 
            p.id, p.nombre, p.descripcion, p.precio, p.stock, 
            p.imagen_url, p.sku, p.activo, p.fecha_creacion, p.fecha_actualizacion,
            c.id AS categoria_id, c.nombre AS categoria_nombre, 
            c.color AS categoria_color, c.icono AS categoria_icono
          FROM productos p
          INNER JOIN categorias c ON p.categoria_id = c.id";

if (!empty($categoria_id)) {
    $query .= " WHERE p.categoria_id = :categoria_id";
}

$query .= " ORDER BY p.nombre ASC";

$stmt = $db->prepare($query);

if (!empty($categoria_id)) {
    $stmt->bindParam(":categoria_id", $categoria_id, PDO::PARAM_INT);
}

$stmt->execute();

// 🟢 Procesar resultados
if ($stmt->rowCount() > 0) {
    $productos = [];

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $productos[] = [
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
    }

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => $productos
    ]);
} else {
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => [],
        "message" => "No se encontraron productos."
    ]);
}
?>