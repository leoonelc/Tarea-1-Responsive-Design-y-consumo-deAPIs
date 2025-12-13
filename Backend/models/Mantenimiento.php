<?php
require_once __DIR__."/../config/Database.php";

class Mantenimiento {
    public static function all() {
        $cn = Database::getConnection();
        $sql = "SELECT m.*, e.nombre AS equipo
                FROM mantenimiento m JOIN equipos e ON e.id=m.id_equipo
                ORDER BY m.fecha DESC";
        return $cn->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function save($data) {
        $cn = Database::getConnection();
        if (empty($data['id'])) {
            $st = $cn->prepare("INSERT INTO mantenimiento (id_equipo,fecha,tipo,descripcion,costo)
                                VALUES (?,?,?,?,?)");
            $st->execute([
                $data['id_equipo'],$data['fecha'],$data['tipo'],
                $data['descripcion'],$data['costo']
            ]);
        } else {
            $st = $cn->prepare("UPDATE mantenimiento SET
                id_equipo=?,fecha=?,tipo=?,descripcion=?,costo=? WHERE id=?");
            $st->execute([
                $data['id_equipo'],$data['fecha'],$data['tipo'],
                $data['descripcion'],$data['costo'],$data['id']
            ]);
        }
    }

    public static function delete($id) {
        $cn = Database::getConnection();
        $cn->prepare("DELETE FROM mantenimiento WHERE id=?")->execute([$id]);
    }
}
