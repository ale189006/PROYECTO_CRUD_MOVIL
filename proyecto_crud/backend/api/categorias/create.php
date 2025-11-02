<?php
// 🚫 Desactivar visualización de errores en la salida (solo logs)
ini_set('display_errors', 0);
error_reporting(E_ALL);

// 🧹 Limpiar cualquier salida previa que pueda romper el JSON
if (ob_get_length()) ob_clean();

// 🟢 Habilitar CORS antes de cualquier salida
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Manejar preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();

    // Leer el cuerpo JSON
    $data = json_decode(file_get_contents("php://input"));

    // Validar que tenga nombre
    if (empty($data->nombre)) {
        ob_clean();
        http_response_code(400);
        echo json_encode([
            "success" => false,
            "message" => "Datos incompletos. El nombre es obligatorio."
        ]);
        exit;
    }

    // Preparar SQL
    $query = "INSERT INTO categorias (nombre, descripcion, icono, color, activo)
              VALUES (:nombre, :descripcion, :icono, :color, :activo)";
    $stmt = $db->prepare($query);

    // Asignar valores
    $nombre = $data->nombre;
    $descripcion = isset($data->descripcion) ? $data->descripcion : '';
    $icono = isset($data->icono) ? $data->icono : '';
    $color = isset($data->color) ? $data->color : '#000000';
    $activo = isset($data->activo) ? (int)$data->activo : 1;

    $stmt->bindParam(":nombre", $nombre);
    $stmt->bindParam(":descripcion", $descripcion);
    $stmt->bindParam(":icono", $icono);
    $stmt->bindParam(":color", $color);
    $stmt->bindParam(":activo", $activo);

    // Ejecutar y responder
    if ($stmt->execute()) {
        ob_clean();
        http_response_code(201);
        echo json_encode([
            "success" => true,
            "message" => "Categoría creada exitosamente.",
            "id" => $db->lastInsertId()
        ]);
        exit;
    } else {
        ob_clean();
        http_response_code(503);
        echo json_encode([
            "success" => false,
            "message" => "No se pudo crear la categoría (Error al ejecutar SQL)."
        ]);
        exit;
    }

} catch (Exception $e) {
    error_log("❌ Error en create.php: " . $e->getMessage());
    ob_clean();
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error interno del servidor: " . $e->getMessage()
    ]);
    exit;
}