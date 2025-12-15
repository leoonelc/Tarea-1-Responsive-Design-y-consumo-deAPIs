<?php
class Mantenimiento {
  public static function all(PDO $db) {
    $sql = "SELECT m.*, e.codigo, e.nombre AS equipo
            FROM mantenimiento m
            INNER JOIN equipos e ON e.id = m.id_equipo
            ORDER BY m.fecha DESC, m.id DESC";
    return $db->query($sql)->fetchAll();
  }

  public static function create(PDO $db, array $p) {
    $sql = "INSERT INTO mantenimiento(id_equipo,fecha,tipo,descripcion,costo)
            VALUES(?,?,?,?,?)";
    $st = $db->prepare($sql);
    $st->execute([
      $p["id_equipo"],
      $p["fecha"],
      $p["tipo"] ?? null,
      $p["descripcion"] ?? null,
      $p["costo"] ?? null
    ]);
    return $db->lastInsertId();
  }

  public static function delete(PDO $db, int $id) {
    $st = $db->prepare("DELETE FROM mantenimiento WHERE id=?");
    return $st->execute([$id]);
  }
}
