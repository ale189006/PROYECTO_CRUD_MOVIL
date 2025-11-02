<?php
// 🟢 Cabeceras CORS — deben ir al inicio siempre
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

$data = json_decode(file_get_contents("php://input"));

// 🟢 Validar datos obligatorios
if (!empty($data->id) && !empty($data->nombre)) {
    $query = "UPDATE categorias 
              SET nombre = :nombre,
                  descripcion = :descripcion,
                  icono = :icono,
                  color = :color,
                  activo = :activo
              WHERE id = :id";
    
    $stmt = $db->prepare($query);
    
    $stmt->bindParam(":id", $data->id);
    $stmt->bindParam(":nombre", $data->nombre);
    $stmt->bindParam(":descripcion", $data->descripcion);
    $stmt->bindParam(":icono", $data->icono);
    $stmt->bindParam(":color", $data->color);
    $stmt->bindParam(":activo", $data->activo);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Categoría actualizada exitosamente."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "success" => false,
            "message" => "No se pudo actualizar la categoría."
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Datos incompletos."
    ]);
}
?>