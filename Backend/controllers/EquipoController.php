<?php
require_once __DIR__ . "/../core/BaseController.php";

class EquipoController extends BaseController {

  // =========================================================
  // UTIL: prefijo 3 letras del departamento (A-Z)
  // =========================================================
  private function depPrefix($depNombre) {
    $pref = strtoupper((string)$depNombre);
    $pref = preg_replace('/[^A-Z]/', '', $pref); // solo letras A-Z
    $pref = substr($pref, 0, 3);
    if (strlen($pref) < 3) $pref = str_pad($pref, 3, "X");
    return $pref;
  }

  // =========================================================
  // UTIL: genera código XXX-PC-001 (secuencial por depto)
  // =========================================================
  private function generarCodigo($depId) {
    // 1) nombre departamento
    $st = $this->db->prepare("SELECT nombre FROM departamentos WHERE id=? LIMIT 1");
    $st->execute([(int)$depId]);
    $dep = $st->fetch();

    $nombre = $dep["nombre"] ?? "DEP";
    $pref = $this->depPrefix($nombre);

    // 2) max correlativo existente en computadoras para ese prefijo
    // formato: XXX-PC-001 (SUBSTRING desde pos 8 toma 3 dígitos)
    $like = $pref . "-PC-%";

    $sql = "
      SELECT MAX(CAST(SUBSTRING(codigo, 8, 3) AS UNSIGNED)) AS maxn
      FROM computadoras
      WHERE codigo LIKE ?
    ";
    $st2 = $this->db->prepare($sql);
    $st2->execute([$like]);
    $row = $st2->fetch();

    $maxn = (int)($row["maxn"] ?? 0);
    $next = $maxn + 1;
    $num  = str_pad((string)$next, 3, "0", STR_PAD_LEFT);

    return $pref . "-PC-" . $num;
  }

  // =========================================================
  // GET ?controller=equipo&action=index
  // =========================================================
  public function index() {
    $sql = "
      SELECT
        c.*,
        d.nombre AS departamento,
        r.nombre AS responsable,
        ua.nombre AS ubicacion_antigua,
        uc.nombre AS ubicacion_actual,
        t.nombre AS tipo_dispositivo
      FROM computadoras c
      LEFT JOIN departamentos d ON d.id = c.id_departamento
      LEFT JOIN responsables r ON r.id = c.responsable_id
      LEFT JOIN ubicaciones ua ON ua.id = c.ubicacion_antigua_id
      LEFT JOIN ubicaciones uc ON uc.id = c.ubicacion_actual_id
      LEFT JOIN tipos_dispositivo t ON t.id = c.tipo_dispositivo_id
      ORDER BY c.id DESC
    ";
    $st = $this->db->query($sql);
    $this->json($st->fetchAll());
  }

  // =========================================================
  // GET ?controller=equipo&action=deps
  // =========================================================
  public function deps() {
    $st = $this->db->query("SELECT id, nombre FROM departamentos ORDER BY nombre");
    $this->json($st->fetchAll());
  }

  // =========================================================
  // GET ?controller=equipo&action=meta
  // =========================================================
  public function meta() {
    $resp = $this->db->query("SELECT id, nombre FROM responsables ORDER BY nombre")->fetchAll();
    $ubis = $this->db->query("SELECT id, nombre FROM ubicaciones ORDER BY nombre")->fetchAll();
    $tipos = $this->db->query("SELECT id, nombre FROM tipos_dispositivo ORDER BY nombre")->fetchAll();

    $this->json([
      "responsables" => $resp,
      "ubicaciones" => $ubis,
      "tipos" => $tipos
    ]);
  }

  // =========================================================
  // ✅ NUEVO: GET ?controller=equipo&action=nextcode&dep_id=#
  // (para que el frontend muestre el código automático)
  // =========================================================
  public function nextcode() {
    $depId = (int)($_GET["dep_id"] ?? 0);
    if ($depId <= 0) $this->json(["ok"=>false,"message"=>"dep_id inválido"], 400);

    $codigo = $this->generarCodigo($depId);
    $this->json(["ok"=>true, "codigo"=>$codigo]);
  }

  // =========================================================
  // POST ?controller=equipo&action=save
  // =========================================================
  public function save() {
    $id = trim($_POST["id"] ?? "");

    $data = [
      "codigo" => trim($_POST["codigo"] ?? ""),
      "nombre" => trim($_POST["nombre"] ?? "Computadora"),
      "marca" => trim($_POST["marca"] ?? ""),
      "modelo" => trim($_POST["modelo"] ?? ""),
      "serie" => trim($_POST["serie"] ?? ""),
      "id_departamento" => (int)($_POST["id_departamento"] ?? 0),
      "responsable_id" => (int)($_POST["responsable_id"] ?? 0),
      "ubicacion_antigua_id" => (int)($_POST["ubicacion_antigua_id"] ?? 0),
      "ubicacion_actual_id" => (int)($_POST["ubicacion_actual_id"] ?? 0),
      "tipo_dispositivo_id" => (int)($_POST["tipo_dispositivo_id"] ?? 0),
      "nombre_dispositivo" => trim($_POST["nombre_dispositivo"] ?? ""),
      "accesorios" => trim($_POST["accesorios"] ?? ""),
      "estado_equipo" => trim($_POST["estado_equipo"] ?? ""),
      "estado" => trim($_POST["estado"] ?? "Activo"),
      "fecha_compra" => trim($_POST["fecha_compra"] ?? ""),
      "licencia_office" => trim($_POST["licencia_office"] ?? ""),
      "licencia_kaspersky" => trim($_POST["licencia_kaspersky"] ?? ""),
      "licencia_windows" => trim($_POST["licencia_windows"] ?? ""),
      "comentarios" => trim($_POST["comentarios"] ?? ""),
    ];

    if ($data["id_departamento"] <= 0) $this->json(["ok"=>false,"message"=>"Departamento requerido"], 400);

    // ✅ Si es NUEVO y viene sin código => generar automático
    if ($id === "" && $data["codigo"] === "") {
      $data["codigo"] = $this->generarCodigo($data["id_departamento"]);
    }

    // (si quieres bloquear edición manual incluso en update, descomenta)
    // if ($id !== "" && $data["codigo"] === "") $this->json(["ok"=>false,"message"=>"Código requerido"], 400);

    if ($data["codigo"] === "") $this->json(["ok"=>false,"message"=>"Código requerido"], 400);

    if ($id !== "") {
      $sql = "
        UPDATE computadoras SET
          codigo=:codigo, nombre=:nombre, marca=:marca, modelo=:modelo, serie=:serie,
          id_departamento=:id_departamento, responsable_id=:responsable_id,
          ubicacion_antigua_id=:ubicacion_antigua_id, ubicacion_actual_id=:ubicacion_actual_id,
          tipo_dispositivo_id=:tipo_dispositivo_id, nombre_dispositivo=:nombre_dispositivo,
          accesorios=:accesorios, estado_equipo=:estado_equipo, estado=:estado,
          fecha_compra=:fecha_compra,
          licencia_office=:licencia_office, licencia_kaspersky=:licencia_kaspersky, licencia_windows=:licencia_windows,
          comentarios=:comentarios
        WHERE id=:id
      ";
      $st = $this->db->prepare($sql);
      $data["id"] = $id;
      $st->execute($data);
      $this->json(["ok"=>true,"message"=>"Actualizado"]);
    } else {

      // ✅ extra: asegurar que el código no exista (por seguridad)
      $chk = $this->db->prepare("SELECT id FROM computadoras WHERE codigo=? LIMIT 1");
      $chk->execute([$data["codigo"]]);
      if ($chk->fetch()) {
        // si por alguna razón ya existe (dos usuarios a la vez), regenera y sigue
        $data["codigo"] = $this->generarCodigo($data["id_departamento"]);
      }

      $sql = "
        INSERT INTO computadoras
        (codigo,nombre,marca,modelo,serie,id_departamento,responsable_id,ubicacion_antigua_id,ubicacion_actual_id,
         tipo_dispositivo_id,nombre_dispositivo,accesorios,estado_equipo,estado,fecha_compra,
         licencia_office,licencia_kaspersky,licencia_windows,comentarios,created_at)
        VALUES
        (:codigo,:nombre,:marca,:modelo,:serie,:id_departamento,:responsable_id,:ubicacion_antigua_id,:ubicacion_actual_id,
         :tipo_dispositivo_id,:nombre_dispositivo,:accesorios,:estado_equipo,:estado,:fecha_compra,
         :licencia_office,:licencia_kaspersky,:licencia_windows,:comentarios,NOW())
      ";
      $st = $this->db->prepare($sql);
      $st->execute($data);
      $this->json(["ok"=>true,"message"=>"Creado","id"=>$this->db->lastInsertId()]);
    }
  }

  // =========================================================
  // POST ?controller=equipo&action=delete
  // =========================================================
  public function delete() {
    $id = (int)($_POST["id"] ?? 0);
    if ($id <= 0) $this->json(["ok"=>false,"message"=>"ID inválido"], 400);

    $st = $this->db->prepare("DELETE FROM computadoras WHERE id=?");
    $st->execute([$id]);

    $this->json(["ok"=>true,"message"=>"Eliminado"]);
  }
}
