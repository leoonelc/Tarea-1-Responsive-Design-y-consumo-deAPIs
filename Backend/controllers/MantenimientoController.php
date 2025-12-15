<?php
require_once __DIR__ . "/../core/BaseController.php";

class MantenimientoController extends BaseController {

  // GET: ?controller=mantenimiento&action=index
  public function index() {
    $sql = "
      SELECT
        m.id,
        m.computadora_id,
        c.codigo AS equipo_codigo,
        c.nombre_dispositivo AS equipo_nombre,
        m.fecha,
        m.tipo,
        m.costo,
        m.descripcion,
        m.created_at
      FROM mantenimiento m
      LEFT JOIN computadoras c ON c.id = m.computadora_id
      ORDER BY m.fecha DESC, m.id DESC
    ";
    $st = $this->db->query($sql);
    $this->json($st->fetchAll(PDO::FETCH_ASSOC));
  }

  // GET: ?controller=mantenimiento&action=equipos
  public function equipos() {
    $st = $this->db->query("SELECT id, codigo, nombre_dispositivo FROM computadoras ORDER BY codigo");
    $this->json($st->fetchAll(PDO::FETCH_ASSOC));
  }

  // POST: ?controller=mantenimiento&action=save
  public function save() {
    $id = trim($_POST["id"] ?? "");
    $computadora_id = (int)($_POST["computadora_id"] ?? 0);
    $fecha = trim($_POST["fecha"] ?? "");
    $tipo = trim($_POST["tipo"] ?? "");
    $costo = trim($_POST["costo"] ?? "0");
    $descripcion = trim($_POST["descripcion"] ?? "");

    if ($computadora_id <= 0) $this->json(["ok"=>false,"message"=>"Equipo requerido"], 400);
    if ($fecha === "") $this->json(["ok"=>false,"message"=>"Fecha requerida"], 400);
    if ($tipo === "") $this->json(["ok"=>false,"message"=>"Tipo requerido"], 400);

    // Normaliza costo (por si viene "36,50")
    $costo = (float) str_replace(",", ".", $costo);

    if ($id !== "") {
      $st = $this->db->prepare("
        UPDATE mantenimiento
        SET computadora_id=?, fecha=?, tipo=?, costo=?, descripcion=?
        WHERE id=?
      ");
      $st->execute([$computadora_id, $fecha, $tipo, $costo, $descripcion, $id]);
      $this->json(["ok"=>true,"message"=>"Actualizado"]);
    } else {
      $st = $this->db->prepare("
        INSERT INTO mantenimiento(computadora_id, fecha, tipo, costo, descripcion, created_at)
        VALUES(?,?,?,?,?, NOW())
      ");
      $st->execute([$computadora_id, $fecha, $tipo, $costo, $descripcion]);
      $this->json(["ok"=>true,"message"=>"Creado", "id"=>$this->db->lastInsertId()]);
    }
  }

  // POST: ?controller=mantenimiento&action=delete
  public function delete() {
    $id = (int)($_POST["id"] ?? 0);
    if ($id <= 0) $this->json(["ok"=>false,"message"=>"ID inválido"], 400);

    $st = $this->db->prepare("DELETE FROM mantenimiento WHERE id=?");
    $st->execute([$id]);

    $this->json(["ok"=>true,"message"=>"Eliminado"]);
  }
}
