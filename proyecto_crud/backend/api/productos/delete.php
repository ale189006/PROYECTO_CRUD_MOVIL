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

// 🟢 Leer el cuerpo JSON recibido
$data = json_decode(file_get_contents("php://input"));

// 🟢 Validar que se envíe el ID
if (!empty($data->id)) {
    $query = "DELETE FROM productos WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $data->id, PDO::PARAM_INT);

    // Ejecutar
    if ($stmt->execute()) {
        // Verificar si realmente se eliminó un registro
        if ($stmt->rowCount() > 0) {
            http_response_code(200);
            echo json_encode([
                "success" => true,
                "message" => "Producto eliminado exitosamente."
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                "success" => false,
                "message" => "No se encontró el producto con ese ID."
            ]);
        }
    } else {
        http_response_code(503);
        echo json_encode([
            "success" => false,
            "message" => "Error al ejecutar la eliminación del producto."
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "El campo 'id' es obligatorio para eliminar un producto."
    ]);
}
?>