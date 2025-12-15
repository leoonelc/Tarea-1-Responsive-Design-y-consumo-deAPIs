<?php
require_once __DIR__ . "/../config/Database.php";

class BaseController {
  /** @var PDO */
  protected $db;

  public function __construct() {
    $this->db = Database::getConnection();
  }

  protected function json($data, int $code = 200) {
    http_response_code($code);
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
  }
}
