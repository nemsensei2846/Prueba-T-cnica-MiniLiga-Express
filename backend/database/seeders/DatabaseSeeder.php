<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Team;
use App\Models\Match;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create teams
        $teams = [
            ['name' => 'Real Madrid', 'city' => 'Madrid'],
            ['name' => 'FC Barcelona', 'city' => 'Barcelona'],
            ['name' => 'Atlético Madrid', 'city' => 'Madrid'],
            ['name' => 'Valencia CF', 'city' => 'Valencia'],
            ['name' => 'Sevilla FC', 'city' => 'Sevilla'],
            ['name' => 'Athletic Bilbao', 'city' => 'Bilbao'],
        ];

        foreach ($teams as $teamData) {
            Team::create($teamData);
        }

        $allTeams = Team::all();

        // Create some sample matches (round-robin style)
        $matches = [];
        for ($i = 0; $i < $allTeams->count(); $i++) {
            for ($j = $i + 1; $j < $allTeams->count(); $j++) {
                // Home match
                $matches[] = [
                    'home_team_id' => $allTeams[$i]->id,
                    'away_team_id' => $allTeams[$j]->id,
                    'played_at' => now()->addDays(rand(1, 30)),
                ];
                
                // Away match (return fixture)
                $matches[] = [
                    'home_team_id' => $allTeams[$j]->id,
                    'away_team_id' => $allTeams[$i]->id,
                    'played_at' => now()->addDays(rand(31, 60)),
                ];
            }
        }

        // Create matches and simulate some results
        foreach ($matches as $index => $matchData) {
            $match = Match::create($matchData);
            
            // Simulate results for first half of matches
            if ($index < count($matches) / 2) {
                $match->update([
                    'home_score' => rand(0, 4),
                    'away_score' => rand(0, 4),
                    'played_at' => now()->subDays(rand(1, 30)),
                ]);
            }
        }
    }
}
