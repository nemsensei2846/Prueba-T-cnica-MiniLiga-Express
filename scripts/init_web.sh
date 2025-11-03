#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -d web/src ]; then
  echo "Angular ya parece estar inicializado en web/. Saliendo."
  exit 0
fi

APP_NAME="web"
API_URL_DEFAULT="http://127.0.0.1:8000"

if command -v ng >/dev/null 2>&1; then
  echo "Creando Angular con Angular CLI..."
  ng new $APP_NAME --directory=web --routing --style=scss --skip-git
else
  echo "No se encontró Angular CLI (ng). Crea el proyecto manualmente siguiendo web/README.md"
  mkdir -p web
fi

cd web
npm pkg set name="@miniliga/web" || true

# Añadir servicio API + dos componentes básicos
if [ -d src ]; then
  npx ng generate service services/api --skip-tests
  npx ng generate component features/teams --skip-tests
  npx ng generate component features/standings --skip-tests

  mkdir -p src/environments
  cat > src/environments/environment.ts <<ENV
export const environment = {
  production: false,
  API_URL: '$API_URL_DEFAULT'
};
ENV

  # Router básico
  cat > src/app/app-routing.module.ts <<'TS'
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { TeamsComponent } from './features/teams/teams.component';
import { StandingsComponent } from './features/standings/standings.component';

const routes: Routes = [
  { path: '', redirectTo: 'teams', pathMatch: 'full' },
  { path: 'teams', component: TeamsComponent },
  { path: 'standings', component: StandingsComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
TS

  # AppModule con HttpClient
  cat > src/app/app.module.ts <<'TS'
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { TeamsComponent } from './features/teams/teams.component';
import { StandingsComponent } from './features/standings/standings.component';

@NgModule({
  declarations: [AppComponent, TeamsComponent, StandingsComponent],
  imports: [BrowserModule, HttpClientModule, ReactiveFormsModule, FormsModule, AppRoutingModule],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {}
TS

  # Servicio API
  cat > src/app/services/api.service.ts <<'TS'
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private base = environment.API_URL;
  constructor(private http: HttpClient) {}
  getTeams() { return this.http.get<any[]>(`${this.base}/api/teams`); }
  createTeam(payload: { name: string }) { return this.http.post(`${this.base}/api/teams`, payload); }
  getStandings() { return this.http.get<any[]>(`${this.base}/api/standings`); }
}
TS

  # Teams component (form + list)
  cat > src/app/features/teams/teams.component.ts <<'TS'
import { Component } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-teams', templateUrl: './teams.component.html' })
export class TeamsComponent {
  teams: any[] = [];
  form = this.fb.group({ name: ['', [Validators.required, Validators.minLength(2)]] });
  loading = false; error = '';
  constructor(private fb: FormBuilder, private api: ApiService) { this.load(); }
  load() { this.api.getTeams().subscribe({ next: t => this.teams = t }); }
  submit() {
    this.error = ''; this.loading = true;
    const val = this.form.value;
    this.api.createTeam({ name: val.name! }).subscribe({
      next: _ => { this.form.reset(); this.load(); this.loading = false; },
      error: e => { this.error = e.error?.message || 'Error'; this.loading = false; }
    });
  }
}
TS
  cat > src/app/features/teams/teams.component.html <<'HTML'
<h2>Equipos</h2>
<form (ngSubmit)="submit()" [formGroup]="form">
  <input type="text" placeholder="Nombre" formControlName="name" />
  <button type="submit" [disabled]="loading || form.invalid">Crear</button>
  <span style="color:red" *ngIf="error">{{error}}</span>
</form>

<table>
  <thead><tr><th>Nombre</th></tr></thead>
  <tbody>
    <tr *ngFor="let t of teams"><td>{{t.name}}</td></tr>
  </tbody>
  </table>
HTML

  # Standings component (table)
  cat > src/app/features/standings/standings.component.ts <<'TS'
import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-standings', templateUrl: './standings.component.html' })
export class StandingsComponent {
  rows: any[] = [];
  constructor(private api: ApiService) { this.api.getStandings().subscribe({ next: r => this.rows = r }); }
}
TS
  cat > src/app/features/standings/standings.component.html <<'HTML'
<h2>Clasificación</h2>
<table>
  <thead>
    <tr>
      <th>Equipo</th><th>PJ</th><th>GF</th><th>GC</th><th>DG</th><th>Pts</th>
    </tr>
  </thead>
  <tbody>
    <tr *ngFor="let r of rows">
      <td>{{r.team}}</td>
      <td>{{r.played}}</td>
      <td>{{r.goals_for}}</td>
      <td>{{r.goals_against}}</td>
      <td>{{r.goal_diff}}</td>
      <td>{{r.points}}</td>
    </tr>
  </tbody>
</table>
HTML

  echo "Esqueleto Angular creado."
else
  echo "No se generó estructura Angular. Revisa web/README.md"
fi
