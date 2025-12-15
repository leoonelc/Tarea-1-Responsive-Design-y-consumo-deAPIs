<?php
require_once __DIR__ . "/../config/Database.php";

class EquipoextrasController {

  // =========================
  // PROGRAMAS
  // =========================

  // GET: ?controller=equipoextras&action=getprogramas&equipo_id=1
  public function getprogramas() {
    $cn = Database::getConnection();

    $equipoId = intval($_GET["equipo_id"] ?? 0);
    if ($equipoId <= 0) {
      $this->out(false, "equipo_id inválido");
    }

    // Catálogo de programas
    $catalogo = $cn->query(
      "SELECT id, nombre FROM programas ORDER BY nombre"
    )->fetchAll();

    // Programas asignados al equipo
    $stmt = $cn->prepare(
      "SELECT programa_id, activo, version
       FROM equipo_programa
       WHERE equipo_id = ?"
    );
    $stmt->execute([$equipoId]);

    $seleccion = [];
    foreach ($stmt->fetchAll() as $row) {
      $seleccion[$row["programa_id"]] = [
        "activo"  => (int)$row["activo"],
        "version" => $row["version"]
      ];
    }

    $this->out(true, null, [
      "catalogo" => $catalogo,
      "seleccion" => $seleccion
    ]);
  }

  // POST JSON
  // ?controller=equipoextras&action=saveprogramas&equipo_id=1
  public function saveprogramas() {
    $cn = Database::getConnection();

    $equipoId = intval($_GET["equipo_id"] ?? 0);
    if ($equipoId <= 0) {
      $this->out(false, "equipo_id inválido");
    }

    $body = json_decode(file_get_contents("php://input"), true);
    $items = $body["items"] ?? [];

    try {
      $cn->beginTransaction();

      $cn->prepare(
        "DELETE FROM equipo_programa WHERE equipo_id = ?"
      )->execute([$equipoId]);

      $stmt = $cn->prepare(
        "INSERT INTO equipo_programa (equipo_id, programa_id, activo, version)
         VALUES (?, ?, ?, ?)"
      );

      foreach ($items as $it) {
        if (empty($it["programa_id"])) continue;

        $stmt->execute([
          $equipoId,
          $it["programa_id"],
          $it["activo"] ?? 0,
          $it["version"] ?? null
        ]);
      }

      $cn->commit();
      $this->out(true);
    } catch (Throwable $e) {
      $cn->rollBack();
      $this->out(false, $e->getMessage(), null, 500);
    }
  }

  // =========================
  // LICENCIAS
  // =========================

  // GET: ?controller=equipoextras&action=getlicencias&equipo_id=1
  public function getlicencias() {
    $cn = Database::getConnection();

    $equipoId = intval($_GET["equipo_id"] ?? 0);
    if ($equipoId <= 0) {
      $this->out(false, "equipo_id inválido");
    }

    $catalogo = $cn->query(
      "SELECT id, nombre FROM licencias ORDER BY nombre"
    )->fetchAll();

    $stmt = $cn->prepare(
      "SELECT licencia_id, activo, clave
       FROM equipo_licencia
       WHERE equipo_id = ?"
    );
    $stmt->execute([$equipoId]);

    $seleccion = [];
    foreach ($stmt->fetchAll() as $row) {
      $seleccion[$row["licencia_id"]] = [
        "activo" => (int)$row["activo"],
        "clave"  => $row["clave"]
      ];
    }

    $this->out(true, null, [
      "catalogo" => $catalogo,
      "seleccion" => $seleccion
    ]);
  }

  // POST JSON
  // ?controller=equipoextras&action=savelicencias&equipo_id=1
  public function savelicencias() {
    $cn = Database::getConnection();

    $equipoId = intval($_GET["equipo_id"] ?? 0);
    if ($equipoId <= 0) {
      $this->out(false, "equipo_id inválido");
    }

    $body = json_decode(file_get_contents("php://input"), true);
    $items = $body["items"] ?? [];

    try {
      $cn->beginTransaction();

      $cn->prepare(
        "DELETE FROM equipo_licencia WHERE equipo_id = ?"
      )->execute([$equipoId]);

      $stmt = $cn->prepare(
        "INSERT INTO equipo_licencia (equipo_id, licencia_id, clave, activo)
         VALUES (?, ?, ?, ?)"
      );

      foreach ($items as $it) {
        if (empty($it["licencia_id"])) continue;

        $stmt->execute([
          $equipoId,
          $it["licencia_id"],
          $it["clave"] ?? null,
          $it["activo"] ?? 0
        ]);
      }

      $cn->commit();
      $this->out(true);
    } catch (Throwable $e) {
      $cn->rollBack();
      $this->out(false, $e->getMessage(), null, 500);
    }
  }

  // =========================
  // RESPUESTA JSON UNIFICADA
  // =========================
private function out(
  bool $ok,
  ?string $msg = null,
  mixed $data = null,
  int $code = 200
) {
  http_response_code($code);
  header("Content-Type: application/json; charset=utf-8");
  echo json_encode([
    "ok" => $ok,
    "message" => $msg,
    "data" => $data
  ], JSON_UNESCAPED_UNICODE);
  exit;
}
}