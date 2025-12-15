import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Equipo {
  id?: number;
  codigo?: string;
  nombre_dispositivo?: string;
  estado?: string;
}

@Injectable({ providedIn: 'root' })
export class EquiposService {

  private API = 'http://localhost/sigat_flodecol/Backend/public/index.php';

  constructor(private http: HttpClient) {}

  listar(): Observable<Equipo[]> {
    return this.http.get<Equipo[]>(`${this.API}?controller=equipo&action=index`);
  }

  crear(data: any) {
    return this.http.post(this.API, { controller: 'equipo', action: 'store', ...data });
  }

  actualizar(data: any) {
    return this.http.post(this.API, { controller: 'equipo', action: 'update', ...data });
  }

  eliminar(id: number) {
    return this.http.post(this.API, { controller: 'equipo', action: 'delete', id });
  }
}
