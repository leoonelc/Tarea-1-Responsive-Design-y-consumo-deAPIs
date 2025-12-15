<?php
require_once __DIR__ . "/../core/BaseController.php";

class DepartamentoController extends BaseController {

  // GET: ?controller=departamento&action=index
  public function index() {
    $st = $this->db->query("SELECT id, nombre FROM departamentos ORDER BY nombre");
    $this->json($st->fetchAll(PDO::FETCH_ASSOC));
  }

  // POST: ?controller=departamento&action=save
  public function save() {
    $id = trim($_POST["id"] ?? "");
    $nombre = trim($_POST["nombre"] ?? "");

    if ($nombre === "") $this->json(["ok"=>false,"message"=>"Nombre requerido"], 400);

    // Evitar duplicados por nombre
    if ($id !== "") {
      $st = $this->db->prepare("SELECT COUNT(*) FROM departamentos WHERE nombre=? AND id<>?");
      $st->execute([$nombre, $id]);
    } else {
      $st = $this->db->prepare("SELECT COUNT(*) FROM departamentos WHERE nombre=?");
      $st->execute([$nombre]);
    }

    if ((int)$st->fetchColumn() > 0) {
      $this->json(["ok"=>false,"message"=>"Ya existe ese departamento"], 409);
    }

    if ($id !== "") {
      $st = $this->db->prepare("UPDATE departamentos SET nombre=? WHERE id=?");
      $st->execute([$nombre, $id]);
      $this->json(["ok"=>true, "message"=>"Actualizado"]);
    } else {
      $st = $this->db->prepare("INSERT INTO departamentos(nombre) VALUES(?)");
      $st->execute([$nombre]);
      $this->json(["ok"=>true, "message"=>"Creado", "id"=>$this->db->lastInsertId()]);
    }
  }

  // POST: ?controller=departamento&action=delete
  public function delete() {
    $id = (int)($_POST["id"] ?? 0);
    if ($id <= 0) $this->json(["ok"=>false,"message"=>"ID inválido"], 400);

    // Si tienes FK desde computadoras/equipos, esto puede fallar (bien).
    try {
      $st = $this->db->prepare("DELETE FROM departamentos WHERE id=?");
      $st->execute([$id]);
      $this->json(["ok"=>true, "message"=>"Eliminado"]);
    } catch (Throwable $e) {
      $this->json(["ok"=>false, "message"=>"No se puede eliminar: está en uso"], 409);
    }
  }
}
