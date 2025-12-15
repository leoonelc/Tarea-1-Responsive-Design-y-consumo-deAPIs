<?php
class Equipo {

  // =========================================================
  // GENERAR CÓDIGO: XXX-PC-001 (por departamento)
  // =========================================================
  public static function generarCodigo($cn, $depId) {
    // 1) obtener nombre del departamento
    $stmt = $cn->prepare("SELECT nombre FROM departamentos WHERE id=? LIMIT 1");
    $stmt->bind_param("i", $depId);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $nombre = $row ? ($row["nombre"] ?? "") : "";

    // 2) prefijo (3 letras) -> solo A-Z
    $pref = strtoupper($nombre);
    $pref = preg_replace('/[^A-Z]/', '', $pref); // elimina espacios, tildes, etc.
    $pref = substr($pref, 0, 3);
    if (strlen($pref) < 3) $pref = str_pad($pref, 3, "X"); // fallback

    // 3) buscar el mayor correlativo existente para ese prefijo
    // formato: XXX-PC-001
    $like = $pref . "-PC-%";

    $sql = "
      SELECT MAX(CAST(SUBSTRING(codigo, 8, 3) AS UNSIGNED)) AS maxn
      FROM equipos
      WHERE codigo LIKE ?
    ";
    $stmt2 = $cn->prepare($sql);
    $stmt2->bind_param("s", $like);
    $stmt2->execute();
    $r2 = $stmt2->get_result()->fetch_assoc();
    $maxn = (int)($r2["maxn"] ?? 0);

    $next = $maxn + 1;
    $num  = str_pad((string)$next, 3, "0", STR_PAD_LEFT);

    return $pref . "-PC-" . $num;
  }
}
