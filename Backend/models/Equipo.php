<?php
require_once __DIR__."/../config/Database.php";

class Equipo {
    public static function all() {
        $cn = Database::getConnection();
        $sql = "SELECT e.*, d.nombre AS departamento
                FROM equipos e LEFT JOIN departamentos d ON d.id=e.id_departamento
                ORDER BY e.nombre";
        return $cn->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function save($data) {
        $cn = Database::getConnection();
        if (empty($data['id'])) {
            $st = $cn->prepare("INSERT INTO equipos
                (codigo,nombre,marca,modelo,serie,id_departamento,estado,fecha_compra)
                VALUES (?,?,?,?,?,?,?,?)");
            $st->execute([
                $data['codigo'],$data['nombre'],$data['marca'],$data['modelo'],
                $data['serie'],$data['id_departamento'],$data['estado'],$data['fecha_compra']
            ]);
        } else {
            $st = $cn->prepare("UPDATE equipos SET
                codigo=?,nombre=?,marca=?,modelo=?,serie=?,id_departamento=?,estado=?,fecha_compra=?
                WHERE id=?");
            $st->execute([
                $data['codigo'],$data['nombre'],$data['marca'],$data['modelo'],
                $data['serie'],$data['id_departamento'],$data['estado'],$data['fecha_compra'],
                $data['id']
            ]);
        }
    }

    public static function delete($id) {
        $cn = Database::getConnection();
        $cn->prepare("DELETE FROM equipos WHERE id=?")->execute([$id]);
    }
}
