import { Component, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { MatTableModule } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

import { MatTableDataSource } from '@angular/material/table';
import { EquiposService, Equipo } from '../../services/equipos.service';

@Component({
  selector: 'app-equipos',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule
  ],
  templateUrl: './equipos.html',
  styleUrl: './equipos.css'
})
export class Equipos {
  private svc = inject(EquiposService);

  cargando = true;
  error = '';

  // UI
  searchText = '';
  fromDate = '';
  toDate = '';

  rowsPerPage = 10;
  pageSizeOptions = [10, 20, 50, 100];

  displayedColumns: string[] = [
    'codigo', 'departamento', 'tipo_dispositivo', 'nombre_dispositivo',
    'accesorios', 'licencia_office', 'licencia_kaspersky', 'licencia_windows',
    'estado_equipo', 'estado', 'created_at', 'acciones'
  ];

  dataSource = new MatTableDataSource<Equipo>([]);
  allRows: Equipo[] = [];

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  ngOnInit() {
    this.cargar();
  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;

    // filtro global (busqueda)
    this.dataSource.filterPredicate = (row: Equipo, filter: string) => {
      const f = (filter || '').toLowerCase().trim();

      // filtro por fecha sobre row.created_at
      if (!this.pasaFiltroFecha(row)) return false;

      if (!f) return true;

      const text = [
        row.codigo,
        row.departamento,
        row.tipo_dispositivo,
        row.nombre_dispositivo,
        row.accesorios,
        row.licencia_office ?? '',
        row.licencia_kaspersky ?? '',
        row.licencia_windows ?? '',
        row.estado_equipo,
        row.estado,
        row.created_at
      ].join(' ').toLowerCase();

      return text.includes(f);
    };
  }

  cargar() {
    this.cargando = true;
    this.error = '';

    this.svc.getEquipos().subscribe({
      next: (rows) => {
        this.allRows = rows ?? [];
        this.dataSource.data = this.allRows;

        // enganchar paginación y sort (si ya existen)
        if (this.paginator) this.dataSource.paginator = this.paginator;
        if (this.sort) this.dataSource.sort = this.sort;

        // set page size inicial
        this.aplicarPageSize(this.rowsPerPage);

        // aplicar filtros
        this.aplicarFiltros();

        this.cargando = false;
      },
      error: (err: any) => {
        this.error = err?.message ?? 'Error cargando equipos';
        this.cargando = false;
      }
    });
  }

  // ✅ se ejecuta al cambiar "Mostrar"
  onRowsChange() {
    this.aplicarPageSize(this.rowsPerPage);
    this.aplicarFiltros();
  }

  aplicarPageSize(n: number) {
    if (!this.paginator) return;
    this.paginator.pageSize = n;
    this.paginator.pageIndex = 0; // ✅ vuelve a pagina 1
    this.dataSource.paginator = this.paginator;
    // fuerza refresh
    this.dataSource._updateChangeSubscription();
  }

  onSearchChange() {
    this.aplicarFiltros();
  }

  onDateChange() {
    this.aplicarFiltros();
  }

  aplicarFiltros() {
    // reset a pagina 1 siempre que cambia filtro
    if (this.paginator) this.paginator.pageIndex = 0;

    // gatilla filterPredicate
    this.dataSource.filter = (this.searchText || '').trim().toLowerCase();
    this.dataSource._updateChangeSubscription();
  }

  pasaFiltroFecha(row: Equipo) {
    const raw = (row.created_at || '').slice(0, 10);
    if (!raw) return true;

    const d = new Date(raw + 'T12:00:00');

    const from = this.fromDate ? new Date(this.fromDate + 'T00:00:00') : null;
    const to = this.toDate ? new Date(this.toDate + 'T23:59:59') : null;

    if (from && d < from) return false;
    if (to && d > to) return false;
    return true;
  }

  fechaSolo(v: string) {
    return (v || '').slice(0, 10);
  }

  // Acciones (luego los conectas a tu modal / editar / eliminar)
  ver(e: Equipo) { alert('VER: ' + e.codigo); }
  editar(e: Equipo) { alert('EDITAR: ' + e.codigo); }
  eliminar(e: Equipo) { alert('ELIMINAR ID: ' + e.id); }
}
