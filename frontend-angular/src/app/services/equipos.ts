import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { EquiposService, Equipo } from '../../services/equipos.service';

@Component({
  selector: 'app-equipos',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './equipos.html'
})
export class EquiposComponent implements OnInit {

  equipos: Equipo[] = [];
  cargando = true;

  modalAbierto = false;
  modoEditar = false;

  form: any = {
    id: null,
    codigo: '',
    nombre_dispositivo: '',
    estado: 'Activo'
  };

  constructor(private equiposService: EquiposService) {}

  ngOnInit(): void {
    this.cargar();
  }

  cargar() {
    this.cargando = true;
    this.equiposService.listar().subscribe(res => {
      this.equipos = res;
      this.cargando = false;
    });
  }

  nuevo() {
    this.modoEditar = false;
    this.form = {
      codigo: '',
      nombre_dispositivo: '',
      estado: 'Activo'
    };
    this.modalAbierto = true;
  }

  editar(e: Equipo) {
    this.modoEditar = true;
    this.form = { ...e };
    this.modalAbierto = true;
  }

  guardar() {
    const req = this.modoEditar
      ? this.equiposService.actualizar(this.form)
      : this.equiposService.crear(this.form);

    req.subscribe(() => {
      this.modalAbierto = false;
      this.cargar();
    });
  }

  eliminar(id?: number) {
    if (!id) return;
    if (!confirm('¿Eliminar equipo?')) return;

    this.equiposService.eliminar(id).subscribe(() => {
      this.cargar();
    });
  }

  cerrarModal() {
    this.modalAbierto = false;
  }
}
