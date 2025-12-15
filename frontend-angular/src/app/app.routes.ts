import { Routes } from '@angular/router';
import { EquiposComponent } from './pages/equipos/equipos';

export const routes: Routes = [
  { path: 'equipos', component: EquiposComponent },
  { path: '', redirectTo: 'equipos', pathMatch: 'full' }
];
