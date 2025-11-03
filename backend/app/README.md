# Backend (Laravel) — MiniLiga Express

## Objetivo
Exponer endpoints:
- `GET /api/teams`
- `POST /api/teams` `{ name }`
- `POST /api/matches/{id}/result` `{ home_score, away_score }`
- `GET /api/standings`

## Instalación rápida (SQLite)
```bash
# Desde la raíz del repo
bash scripts/init_backend.sh

cd backend
php artisan migrate --seed
php artisan serve
```

## Migraciones sugeridas

### database/migrations/xxxx_create_teams_table.php
```php
public function up(): void {
    Schema::create('teams', function (Blueprint $table) {
        $table->id();
        $table->string('name')->unique();
        $table->integer('goals_for')->default(0);
        $table->integer('goals_against')->default(0);
        $table->timestamps();
    });
}
```

### database/migrations/xxxx_create_matches_table.php
```php
public function up(): void {
    Schema::create('matches', function (Blueprint $table) {
        $table->id();
        $table->foreignId('home_team_id')->constrained('teams');
        $table->foreignId('away_team_id')->constrained('teams');
        $table->integer('home_score')->nullable();
        $table->integer('away_score')->nullable();
        $table->dateTime('played_at')->nullable();
        $table->timestamps();
    });
}
```

## Seed (ejemplo)
```php
public function run(): void {
    $teams = collect(['Dragons','Sharks','Tigers','Wolves'])
      ->map(fn($n)=>App\Models\Team::create(['name'=>$n]));

    // crea 2-3 partidos sin resultado
    App\Models\Match::create([
      'home_team_id'=>$teams[0]->id, 'away_team_id'=>$teams[1]->id
    ]);
    App\Models\Match::create([
      'home_team_id'=>$teams[2]->id, 'away_team_id'=>$teams[3]->id
    ]);
}
```

## Lógica standings (orientativa)
- `points`: W=3, D=1, L=0.
- `played`: partidos con `home_score` y `away_score` no nulos.
- Orden: `points DESC`, `goal_diff DESC`, `goals_for DESC`.

## Test mínimo (Pest o PHPUnit)
- Crea dos equipos, un partido y registra dos resultados (victoria y empate) asegurando que los puntos se calculan correctamente.