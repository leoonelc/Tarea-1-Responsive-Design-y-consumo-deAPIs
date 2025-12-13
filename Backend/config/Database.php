<?php
class Database {
    public static function getConnection() {
        $cn = new PDO("mysql:host=localhost;dbname=InventarioEquiposTI_DB;charset=utf8","root","");
        $cn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $cn;
    }
}
