<?php
// Archivo de prueba para CORS
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 86400");

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

echo json_encode([
    "success" => true,
    "message" => "CORS configurado correctamente",
    "timestamp" => date('Y-m-d H:i:s'),
    "origin" => $_SERVER['HTTP_ORIGIN'] ?? 'No origin header',
    "method" => $_SERVER['REQUEST_METHOD'],
    "headers" => getallheaders()
], JSON_PRETTY_PRINT);
?>
