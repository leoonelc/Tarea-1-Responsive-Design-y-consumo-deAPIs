<?php
class Database {

  /** @return PDO */
  public static function getConnection() {
    $host = "127.0.0.1";
    $db   = "sigat_flodecol";
    $user = "root";
    $pass = "";

    $cn = new PDO(
      "mysql:host={$host};dbname={$db};charset=utf8mb4",
      $user,
      $pass,
      [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
      ]
    );

    return $cn;
  }

  // Alias por si en algún archivo viejo usan Database::connect()
  public static function connect() {
    return self::getConnection();
  }
}
