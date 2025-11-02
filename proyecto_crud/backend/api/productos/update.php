<?php
// 🟢 Cabeceras CORS y JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// 🟢 Mostrar errores (solo en desarrollo)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// 🟢 Manejar preflight (OPTIONS)
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
        "message" => "Error de conexión a la base de datos. Asegúrate de que XAMPP esté ejecutándose y que la BD exista."
    ]);
    exit();
}

// 🟢 Leer JSON del cuerpo
$input = file_get_contents("php://input");
$data = json_decode($input);

// 🟢 Validar formato JSON
if (!$data) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Formato JSON inválido o cuerpo vacío."
    ]);
    exit();
}

// 🟢 Validar campos mínimos obligatorios
if (empty($data->id) || empty($data->nombre) || empty($data->categoria_id)) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Datos incompletos: ID, nombre y categoría son obligatorios."
    ]);
    exit();
}

// 🟢 Preparar query segura
$query = "UPDATE productos 
          SET categoria_id = :categoria_id,
              nombre = :nombre,
              descripcion = :descripcion,
              precio = :precio,
              stock = :stock,
              imagen_url = :imagen_url,
              sku = :sku,
              activo = :activo,
              fecha_actualizacion = NOW()
          WHERE id = :id";

$stmt = $db->prepare($query);

// 🟢 Normalizar datos (permite vacíos sin error)
$id = intval($data->id);
$categoria_id = intval($data->categoria_id);
$nombre = htmlspecialchars(strip_tags($data->nombre));
$descripcion = isset($data->descripcion) ? htmlspecialchars(strip_tags($data->descripcion)) : "";
$precio = isset($data->precio) && is_numeric($data->precio) ? floatval($data->precio) : 0;
$stock = isset($data->stock) && is_numeric($data->stock) ? intval($data->stock) : 0;
$imagen_url = isset($data->imagen_url) ? htmlspecialchars(strip_tags($data->imagen_url)) : "";
$sku = isset($data->sku) && trim($data->sku) !== "" ? htmlspecialchars(strip_tags($data->sku)) : null;
$activo = isset($data->activo) ? intval($data->activo) : 1;

// 🟢 Vincular parámetros
$stmt->bindParam(":id", $id, PDO::PARAM_INT);
$stmt->bindParam(":categoria_id", $categoria_id, PDO::PARAM_INT);
$stmt->bindParam(":nombre", $nombre);
$stmt->bindParam(":descripcion", $descripcion);
$stmt->bindParam(":precio", $precio);
$stmt->bindParam(":stock", $stock, PDO::PARAM_INT);
$stmt->bindParam(":imagen_url", $imagen_url);

// 🟢 Si SKU está vacío → se guarda como NULL
if ($sku === null) {
    $stmt->bindValue(":sku", null, PDO::PARAM_NULL);
} else {
    $stmt->bindValue(":sku", $sku, PDO::PARAM_STR);
}

$stmt->bindParam(":activo", $activo, PDO::PARAM_INT);

// 🟢 Ejecutar actualización
try {
    if ($stmt->execute()) {
        $filas = $stmt->rowCount();

        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => $filas > 0
                ? "✅ Producto actualizado correctamente."
                : "⚠️ No se realizaron cambios (verifica si los datos son iguales)."
        ]);
    } else {
        http_response_code(503);
        echo json_encode([
            "success" => false,
            "message" => "Error al ejecutar la actualización."
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error SQL: " . $e->getMessage()
    ]);
}
?>