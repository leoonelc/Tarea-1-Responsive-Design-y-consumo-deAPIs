<?php
require_once __DIR__."/../core/BaseController.php";
require_once __DIR__."/../models/Equipo.php";
require_once __DIR__."/../models/Departamento.php";

class EquipoController extends BaseController {
    public function index() {
        $this->json( Equipo::all() );
    }

    public function save() {
        Equipo::save($_POST);
        $this->json(['ok'=>true]);
    }

    public function delete() {
        Equipo::delete($_POST['id']);
        $this->json(['ok'=>true]);
    }

    public function deps() {       // para llenar combos
        $this->json( Departamento::all() );
    }
}
