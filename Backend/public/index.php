<?php
// ===============================
// CORS (para Angular)
// ===============================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

// ===============================
// CARGA DEPENDENCIAS (1 sola vez)
// ===============================
require_once __DIR__ . "/../config/Database.php";
require_once __DIR__ . "/../core/Router.php";
require_once __DIR__ . "/../core/BaseController.php";

// Controllers
require_once __DIR__ . "/../controllers/EquipoController.php";
require_once __DIR__ . "/../controllers/DepartamentoController.php";
require_once __DIR__ . "/../controllers/MantenimientoController.php";

// ===============================
// DISPATCH (1 sola vez)
// ===============================
Router::dispatch();
