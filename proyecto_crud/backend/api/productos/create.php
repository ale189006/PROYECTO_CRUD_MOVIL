<?php
// 🟢 Cabeceras CORS (deben ir antes de cualquier salida)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight requests (muy importante para Flutter Web)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

$database = new Database();
$db = $database->getConnection();

// 🟢 Obtener y decodificar el cuerpo JSON
$data = json_decode(file_get_contents("php://input"));

// 🟢 Validar datos requeridos
if (!empty($data->nombre) && !empty($data->categoria_id)) {
    $query = "INSERT INTO productos (
                  categoria_id, nombre, descripcion, precio, stock, imagen_url, sku, activo
              ) VALUES (
                  :categoria_id, :nombre, :descripcion, :precio, :stock, :imagen_url, :sku, :activo
              )";
    
    $stmt = $db->prepare($query);

    // Vincular parámetros
    $stmt->bindParam(":categoria_id", $data->categoria_id);
    $stmt->bindParam(":nombre", $data->nombre);
    $stmt->bindParam(":descripcion", $data->descripcion);
    $stmt->bindParam(":precio", $data->precio);
    $stmt->bindParam(":stock", $data->stock);
    $stmt->bindParam(":imagen_url", $data->imagen_url);
    $stmt->bindParam(":sku", $data->sku);
    
    // Si no se envía "activo", se asume true
    $activo = isset($data->activo) ? $data->activo : true;
    $stmt->bindParam(":activo", $activo);

    // Ejecutar la inserción
    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode([
            "success" => true,
            "message" => "Producto creado correctamente.",
            "id" => $db->lastInsertId()
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "success" => false,
            "message" => "Error al crear el producto."
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Datos incompletos: 'nombre' y 'categoria_id' son obligatorios."
    ]);
}
?>