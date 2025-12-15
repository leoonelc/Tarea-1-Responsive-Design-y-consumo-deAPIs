<?php

class Router {

  public static function dispatch() {
    $controllerName = strtolower($_GET["controller"] ?? "");
    $action = strtolower($_GET["action"] ?? "index");

    if ($controllerName === "") {
      self::out(["ok"=>false, "message"=>"Controller no encontrado", "controller"=>""]);
    }

    $className = ucfirst($controllerName) . "Controller";
    $file = __DIR__ . "/../controllers/{$className}.php";

    if (!file_exists($file)) {
      self::out(["ok"=>false, "message"=>"Controller no encontrado", "controller"=>$controllerName], 404);
    }

    require_once $file;

    if (!class_exists($className)) {
      self::out(["ok"=>false, "message"=>"Clase controller no encontrada", "class"=>$className], 500);
    }

    $ctrl = new $className();

    if (!method_exists($ctrl, $action)) {
      self::out(["ok"=>false, "message"=>"Acción no encontrada", "action"=>$action], 404);
    }

    // Ejecuta acción
    $ctrl->$action();
  }

  private static function out($data, int $code = 200) {
    http_response_code($code);
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
  }
}
