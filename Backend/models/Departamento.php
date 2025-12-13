<?php
require_once __DIR__."/../config/Database.php";

class Departamento {
    public static function all() {
        $cn = Database::getConnection();
        return $cn->query("SELECT * FROM departamentos ORDER BY nombre")->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function save($data) {
        $cn = Database::getConnection();
        if (empty($data['id'])) {
            $st = $cn->prepare("INSERT INTO departamentos(nombre) VALUES (?)");
            $st->execute([$data['nombre']]);
        } else {
            $st = $cn->prepare("UPDATE departamentos SET nombre=? WHERE id=?");
            $st->execute([$data['nombre'],$data['id']]);
        }
    }

    public static function delete($id) {
        $cn = Database::getConnection();
        $cn->prepare("DELETE FROM departamentos WHERE id=?")->execute([$id]);
    }
}
