#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -d mobile/src ]; then
  echo "Ionic ya parece estar inicializado en mobile/. Saliendo."
  exit 0
fi

API_URL_DEFAULT="http://127.0.0.1:8000"

if command -v ionic >/dev/null 2>&1; then
  echo "Creando Ionic con Ionic CLI..."
  ionic start mobile tabs --type=angular --no-git --capacitor --package-id=com.miniliga.app --confirm
else
  echo "No se encontró Ionic CLI. Crea el proyecto manualmente siguiendo mobile/README.md"
  mkdir -p mobile
fi

cd mobile || exit 0

# Config de entorno
mkdir -p src/environments
cat > src/environments/environment.ts <<ENV
export const environment = {
  production: false,
  API_URL: '$API_URL_DEFAULT'
};
ENV

# Página sencilla para matches y report-result
if [ -d src/app ]; then
  npx ng g page pages/matches --skip-tests
  npx ng g page pages/report-result --skip-tests
  npx ng g service services/api --skip-tests || true
  echo "Esqueleto Ionic creado."
fi

# Servicio API
if [ -d src/app ]; then
  cat > src/app/services/api.service.ts <<'TS'
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  base = environment.API_URL;
  constructor(private http: HttpClient) {}
  getPendingMatches() { return this.http.get<any[]>(`${this.base}/api/matches?played=false`); }
  reportResult(id: number, payload: { home_score: number; away_score: number }) {
    return this.http.post(`${this.base}/api/matches/${id}/result`, payload);
  }
}
TS

  # Matches page
  cat > src/app/pages/matches/matches.page.ts <<'TS'
import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-matches', templateUrl: './matches.page.html' })
export class MatchesPage {
  matches: any[] = [];
  constructor(private api: ApiService) { this.load(); }
  load() { this.api.getPendingMatches().subscribe({ next: m => this.matches = m, error: _ => this.matches = [] }); }
}
TS
  cat > src/app/pages/matches/matches.page.html <<'HTML'
<ion-header>
  <ion-toolbar><ion-title>Partidos</ion-title></ion-toolbar>
  </ion-header>
<ion-content>
  <ion-list>
    <ion-item *ngFor="let m of matches">
      <ion-label>
        <h2>{{m.home_team?.name || m.home_team_id}} vs {{m.away_team?.name || m.away_team_id}}</h2>
      </ion-label>
    </ion-item>
  </ion-list>
</ion-content>
HTML

  # Report result page
  cat > src/app/pages/report-result/report-result.page.ts <<'TS'
import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-report-result', templateUrl: './report-result.page.html' })
export class ReportResultPage {
  id = 1; home_score = 0; away_score = 0; message = '';
  constructor(private api: ApiService) {}
  submit() {
    this.api.reportResult(this.id, { home_score: this.home_score, away_score: this.away_score }).subscribe({
      next: _ => this.message = 'Enviado',
      error: e => this.message = e.error?.message || 'Error'
    });
  }
}
TS
  cat > src/app/pages/report-result/report-result.page.html <<'HTML'
<ion-header>
  <ion-toolbar><ion-title>Reportar resultado</ion-title></ion-toolbar>
</ion-header>
<ion-content>
  <ion-item>
    <ion-label position="stacked">Partido ID</ion-label>
    <ion-input type="number" [(ngModel)]="id"></ion-input>
  </ion-item>
  <ion-item>
    <ion-label position="stacked">Home</ion-label>
    <ion-input type="number" [(ngModel)]="home_score"></ion-input>
  </ion-item>
  <ion-item>
    <ion-label position="stacked">Away</ion-label>
    <ion-input type="number" [(ngModel)]="away_score"></ion-input>
  </ion-item>
  <ion-button expand="block" (click)="submit()">Enviar</ion-button>
  <ion-text color="primary">{{message}}</ion-text>
</ion-content>
HTML
fi
