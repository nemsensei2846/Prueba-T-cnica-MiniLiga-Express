<?php

namespace App\Http\Controllers;

use App\Models\Match;
use App\Models\Team;
use Illuminate\Http\JsonResponse;

class StandingsController extends Controller
{
    public function index(): JsonResponse
    {
        $teams = Team::query()->orderBy('name')->get();
        $matches = Match::query()->played()->get();

        $table = [];
        foreach ($teams as $team) {
            $table[$team->id] = [
                'team' => $team,
                'played' => 0,
                'wins' => 0,
                'draws' => 0,
                'losses' => 0,
                'goals_for' => 0,
                'goals_against' => 0,
                'goal_diff' => 0,
                'points' => 0,
            ];
        }

        foreach ($matches as $match) {
            $home = &$table[$match->home_team_id];
            $away = &$table[$match->away_team_id];

            $home['played']++;
            $away['played']++;

            $home['goals_for'] += $match->home_score;
            $home['goals_against'] += $match->away_score;
            $away['goals_for'] += $match->away_score;
            $away['goals_against'] += $match->home_score;

            if ($match->home_score > $match->away_score) {
                $home['wins']++;
                $away['losses']++;
                $home['points'] += 3;
            } elseif ($match->home_score < $match->away_score) {
                $away['wins']++;
                $home['losses']++;
                $away['points'] += 3;
            } else {
                $home['draws']++;
                $away['draws']++;
                $home['points'] += 1;
                $away['points'] += 1;
            }
        }

        foreach ($table as &$row) {
            $row['goal_diff'] = $row['goals_for'] - $row['goals_against'];
        }

        $standings = array_values($table);
        usort($standings, function ($a, $b) {
            return [$b['points'], $b['goal_diff'], $b['goals_for']] <=> [$a['points'], $a['goal_diff'], $a['goals_for']];
        });

        return response()->json($standings);
    }
}