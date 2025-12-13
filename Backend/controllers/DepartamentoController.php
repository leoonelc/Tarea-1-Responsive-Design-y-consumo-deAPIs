<?php
require_once __DIR__."/../core/BaseController.php";
require_once __DIR__."/../models/Departamento.php";

class DepartamentoController extends BaseController {
    public function index() {
        $this->json( Departamento::all() );
    }

    public function save() {
        Departamento::save($_POST);
        $this->json(['ok'=>true]);
    }

    public function delete() {
        Departamento::delete($_POST['id']);
        $this->json(['ok'=>true]);
    }
}
