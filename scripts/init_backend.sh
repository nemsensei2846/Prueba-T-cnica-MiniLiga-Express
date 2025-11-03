#!/usr/bin/env bash
set -euo pipefail

# Requisitos: PHP >= 8.2, Composer, SQLite (o MySQL si adaptas)
# Si no tienes instalador de Laravel global, usaremos Composer create-project.

cd "$(dirname "$0")/.."

if [ -d backend/app ]; then
  echo "Laravel ya parece estar inicializado en backend/. Saliendo."
  exit 0
fi

echo "Creando proyecto Laravel en backend/ ..."
composer create-project laravel/laravel backend

cd backend

echo "Instalando dependencias útiles..."
composer require laravel/sanctum --no-interaction

echo "Configurando SQLite para rapidez..."
cp .env .env.example || true
cp .env.example .env
mkdir -p database
touch database/database.sqlite
php -r "file_put_contents('.env', preg_replace('/^DB_CONNECTION=.*/m','DB_CONNECTION=sqlite', file_get_contents('.env')));"
php -r "file_put_contents('.env', preg_replace('/^DB_DATABASE=.*/m,'DB_DATABASE=' . __DIR__ . '/database/database.sqlite', file_get_contents('.env')));"

echo "Creando migraciones y modelos..."
php artisan make:model Team -m
php artisan make:model Match -m
php artisan make:seeder TeamsAndMatchesSeeder
php artisan make:test StandingsTest

echo "Generando controlador API..."
php artisan make:controller Api/TeamController --api
php artisan make:controller Api/MatchController --api
php artisan make:controller Api/StandingsController

echo "Añadiendo rutas API..."
# Agrega marcador para insertar rutas si no existe
grep -q 'MINILIGA_ROUTES' routes/api.php || cat >> routes/api.php <<'PHP'

// === MINILIGA_ROUTES (auto) ===
use App\Http\Controllers\Api\TeamController;
use App\Http\Controllers\Api\MatchController;
use App\Http\Controllers\Api\StandingsController;

Route::get('/teams', [TeamController::class, 'index']);
Route::post('/teams', [TeamController::class, 'store']);
Route::get('/matches', [MatchController::class, 'index']);
Route::post('/matches/{id}/result', [MatchController::class, 'result']);
Route::get('/standings', [StandingsController::class, 'index']);
// === /MINILIGA_ROUTES ===
PHP

echo "Rellenando migraciones de Teams y Matches..."
# Equipos
TEAM_MIG=$(ls database/migrations/*_create_teams_table.php | head -n1)
cat > "$TEAM_MIG" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->integer('goals_for')->default(0);
            $table->integer('goals_against')->default(0);
            $table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('teams');
    }
};
PHP

# Partidos
MATCH_MIG=$(ls database/migrations/*_create_matches_table.php | head -n1)
cat > "$MATCH_MIG" <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
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
    public function down(): void {
        Schema::dropIfExists('matches');
    }
};
PHP

echo "Rellenando seeder TeamsAndMatchesSeeder..."
cat > database/seeders/TeamsAndMatchesSeeder.php <<'PHP'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Team;
use App\Models\Match;

class TeamsAndMatchesSeeder extends Seeder
{
    public function run(): void
    {
        $names = ['Dragons','Sharks','Tigers','Wolves'];
        $teams = [];
        foreach ($names as $n) {
            $teams[] = Team::create(['name' => $n]);
        }

        // 2-3 partidos pendientes
        Match::create(['home_team_id' => $teams[0]->id, 'away_team_id' => $teams[1]->id]);
        Match::create(['home_team_id' => $teams[2]->id, 'away_team_id' => $teams[3]->id]);
        Match::create(['home_team_id' => $teams[0]->id, 'away_team_id' => $teams[2]->id]);
    }
}
PHP

echo "Actualizando DatabaseSeeder para llamar a TeamsAndMatchesSeeder..."
sed -i.bak "s/\(run\(\): void {\)/\1\n        \$this->call(TeamsAndMatchesSeeder::class);/" database/seeders/DatabaseSeeder.php || true
grep -q TeamsAndMatchesSeeder database/seeders/DatabaseSeeder.php || cat >> database/seeders/DatabaseSeeder.php <<'PHP'
    public function run(): void
    {
        $this->call(TeamsAndMatchesSeeder::class);
    }
PHP

echo "Implementando controladores API..."
cat > app/Http/Controllers/Api/TeamController.php <<'PHP'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Team;

class TeamController extends Controller
{
    public function index()
    {
        return response()->json(Team::orderBy('name')->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|min:2|max:50|unique:teams,name',
        ]);
        $team = Team::create(['name' => $data['name']]);
        return response()->json($team, 201);
    }
}
PHP

cat > app/Http/Controllers/Api/MatchController.php <<'PHP'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Match;
use App\Models\Team;

class MatchController extends Controller
{
    public function index(Request $request)
    {
        $played = $request->boolean('played', null);
        $q = Match::query();
        if ($played === true) {
            $q->whereNotNull('home_score')->whereNotNull('away_score');
        } elseif ($played === false) {
            $q->whereNull('home_score')->whereNull('away_score');
        }
        return response()->json($q->orderBy('id','desc')->get());
    }

    public function result($id, Request $request)
    {
        $data = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $match = Match::findOrFail($id);
        $match->home_score = $data['home_score'];
        $match->away_score = $data['away_score'];
        $match->played_at = now();
        $match->save();

        $home = Team::findOrFail($match->home_team_id);
        $away = Team::findOrFail($match->away_team_id);
        $home->goals_for += $match->home_score;
        $home->goals_against += $match->away_score;
        $away->goals_for += $match->away_score;
        $away->goals_against += $match->home_score;
        $home->save();
        $away->save();

        return response()->json(['ok' => true]);
    }
}
PHP

cat > app/Http/Controllers/Api/StandingsController.php <<'PHP'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Team;
use App\Models\Match;

class StandingsController extends Controller
{
    public function index()
    {
        $teams = Team::all();
        $matches = Match::whereNotNull('home_score')->whereNotNull('away_score')->get();

        $stats = [];
        foreach ($teams as $t) {
            $played = 0; $wins = 0; $draws = 0; $losses = 0;
            foreach ($matches as $m) {
                if ($m->home_team_id == $t->id || $m->away_team_id == $t->id) {
                    $played++;
                    $hs = $m->home_score; $as = $m->away_score;
                    if ($m->home_team_id == $t->id) {
                        if ($hs > $as) $wins++; elseif ($hs == $as) $draws++; else $losses++;
                    } else {
                        if ($as > $hs) $wins++; elseif ($as == $hs) $draws++; else $losses++;
                    }
                }
            }
            $points = $wins * 3 + $draws;
            $stats[] = [
                'team' => $t->name,
                'played' => $played,
                'goals_for' => $t->goals_for,
                'goals_against' => $t->goals_against,
                'goal_diff' => $t->goals_for - $t->goals_against,
                'points' => $points,
            ];
        }

        usort($stats, function ($a, $b) {
            return [$b['points'], $b['goal_diff'], $b['goals_for']] <=> [$a['points'], $a['goal_diff'], $a['goals_for']];
        });

        return response()->json(array_values($stats));
    }
}
PHP

echo "Creando test mínimo de standings..."
cat > tests/Feature/StandingsTest.php <<'PHP'
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Team;
use App\Models\Match;

class StandingsTest extends TestCase
{
    use RefreshDatabase;

    public function test_standings_calculation()
    {
        $a = Team::create(['name' => 'A']);
        $b = Team::create(['name' => 'B']);

        $m1 = Match::create(['home_team_id' => $a->id, 'away_team_id' => $b->id]);

        // Reportar resultado 2-1
        $this->postJson('/api/matches/'.$m1->id.'/result', ['home_score' => 2, 'away_score' => 1])
             ->assertStatus(200);

        // Consultar standings
        $res = $this->getJson('/api/standings')->assertStatus(200)->json();

        // A debe ir delante con 3 puntos
        $this->assertEquals('A', $res[0]['team']);
        $this->assertEquals(3, $res[0]['points']);
        $this->assertEquals('B', $res[1]['team']);
        $this->assertEquals(0, $res[1]['points']);
    }
}
PHP

echo "Escribe las migraciones según el README de backend/ y luego:"
echo "  php artisan migrate --seed"
echo "  php artisan serve"
