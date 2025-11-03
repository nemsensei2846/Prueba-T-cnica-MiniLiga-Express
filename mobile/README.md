# Móvil (Ionic + Capacitor) — MiniLiga Express

## Objetivo
- Página **Matches**: lista de próximos (sin resultado).
- Página **Report Result**: form `home_score`, `away_score` → POST a `/api/matches/{id}/result`.

## Instalación
```bash
bash ../scripts/init_mobile.sh
npm start
```

## Servicio API (ejemplo)
`src/app/services/api.service.ts`:
```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  base = environment.API_URL;
  constructor(private http: HttpClient) {}
  getPendingMatches() { return this.http.get<any[]>(`${this.base}/api/matches?played=false`); } // o mock
  reportResult(id: number, payload: { home_score: number; away_score: number }) {
    return this.http.post(`${this.base}/api/matches/${id}/result`, payload);
  }
}
```

## Bonus (opcional)
- `@capacitor/camera` para previsualizar una foto antes de enviar (no obligatorio).
