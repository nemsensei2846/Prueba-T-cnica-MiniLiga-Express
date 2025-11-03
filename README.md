# Prueba técnica — MiniLiga Express (≤ 4 h)

Este repositorio es una **semilla** lista para que los candidatos clonen y completen la prueba express en ≤ 4 horas.  
Incluye estructura, documentación y **scripts** que generan los proyectos de **Laravel**, **Angular** e **Ionic/Capacitor**.

> Instrucciones detalladas en cada subcarpeta: `backend/`, `web/`, `mobile/`.

## Resumen del MVP
- **Laravel** API:
  - `GET /api/teams`
  - `POST /api/teams` `{ name }`
  - `POST /api/matches/{id}/result` `{ home_score, away_score }`
  - `GET /api/standings`
- **Angular**:
  - Pestaña **Equipos** (alta + listado)
  - Pestaña **Clasificación**
- **Ionic/Capacitor**:
  - Lista de próximos partidos
  - Registrar resultado (POST al backend)

## Scripts de inicialización
Ejecuta desde la raíz.

macOS/Linux:

```bash
bash scripts/init_backend.sh
bash scripts/init_web.sh
bash scripts/init_mobile.sh
```

> Los scripts usan los CLI oficiales (`laravel new`, `ng new`, `ionic start`) si están disponibles.  
> Alternativamente, sigue los pasos manuales en los README de cada carpeta.

Windows (PowerShell):

```powershell
scripts/init_backend.ps1
scripts/init_web.ps1
scripts/init_mobile.ps1
```

Si no tienes WSL/Git Bash instalados, ejecuta los comandos manuales indicados en cada README. Recuerda configurar `API_URL` en `mobile/src/environments/environment.ts` (por defecto `http://127.0.0.1:8000`).

## Flujo de Git recomendado
- Crea ramas por feature: `feature/backend-standings`, `feature/web-teams`, `feature/mobile-report`.
- Haz commits claros y pequeños (mensaje imperativo breve).
- Abre PRs descriptivos (qué cambia, por qué, cómo probarlo).
- Merge tras revisión. Mantén `main` siempre desplegable.

## Extras (opcionales)
- Camera preview en móvil.
- Orden de standings por `points`, `goal_diff`, `goals_for`.
- Docker Compose con MySQL.