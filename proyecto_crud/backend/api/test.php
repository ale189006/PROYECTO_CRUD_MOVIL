<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Test de conexión a la base de datos
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$response = array(
    "success" => true,
    "message" => "API funcionando correctamente",
    "timestamp" => date('Y-m-d H:i:s'),
    "database_connection" => $db !== null ? "OK" : "ERROR",
    "server_info" => array(
        "php_version" => phpversion(),
        "server_software" => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        "request_method" => $_SERVER['REQUEST_METHOD'],
        "request_uri" => $_SERVER['REQUEST_URI']
    )
);

if ($db === null) {
    $response["success"] = false;
    $response["message"] = "Error de conexión a la base de datos";
    $response["database_connection"] = "ERROR";
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
