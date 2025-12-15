<?php
class Departamento {
  public static function all(PDO $db) {
    return $db->query("SELECT id, nombre FROM departamentos ORDER BY nombre")->fetchAll();
  }

  public static function create(PDO $db, string $nombre) {
    $st = $db->prepare("INSERT INTO departamentos(nombre) VALUES(?)");
    $st->execute([$nombre]);
    return $db->lastInsertId();
  }

  public static function update(PDO $db, int $id, string $nombre) {
    $st = $db->prepare("UPDATE departamentos SET nombre=? WHERE id=?");
    return $st->execute([$nombre, $id]);
  }

  public static function delete(PDO $db, int $id) {
    $st = $db->prepare("DELETE FROM departamentos WHERE id=?");
    return $st->execute([$id]);
  }
}
