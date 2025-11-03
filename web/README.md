# Web (Angular) — MiniLiga Express

## Objetivo
Dos pestañas:
1) **Equipos**: listado + alta.
2) **Clasificación**: tabla desde `GET /api/standings`.

## Instalación
```bash
bash ../scripts/init_web.sh
npm start
```

## API Service (ejemplo)
Crea `src/app/services/api.service.ts`:
```ts
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
```

## UI mínima
- `TeamsComponent`: formulario reactivo `{ name }` y tabla.
- `StandingsComponent`: tabla con `team`, `played`, `goals_for`, `goals_against`, `goal_diff`, `points`.
