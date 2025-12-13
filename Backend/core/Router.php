<?php
class Router {
    public static function route() {
        $c = $_GET['controller'] ?? 'equipo';
        $a = $_GET['action'] ?? 'index';

        $controllerName = ucfirst($c).'Controller';
        require_once __DIR__."/../controllers/{$controllerName}.php";
        $controller = new $controllerName();
        $controller->$a();
    }
}

