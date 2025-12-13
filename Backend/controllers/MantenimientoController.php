<?php
require_once __DIR__."/../core/BaseController.php";
require_once __DIR__."/../models/Mantenimiento.php";
require_once __DIR__."/../models/Equipo.php";

class MantenimientoController extends BaseController {
    public function index() {
        $this->json( Mantenimiento::all() );
    }

    public function save() {
        Mantenimiento::save($_POST);
        $this->json(['ok'=>true]);
    }

    public function delete() {
        Mantenimiento::delete($_POST['id']);
        $this->json(['ok'=>true]);
    }

    public function equipos() {
        $this->json( Equipo::all() );
    }
}
