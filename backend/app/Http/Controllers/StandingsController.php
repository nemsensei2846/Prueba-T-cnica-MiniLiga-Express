<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Match;
use Illuminate\Http\JsonResponse;

class StandingsController extends Controller
{
    /**
     * Display the league standings.
     */
    public function index(): JsonResponse
    {
        $teams = Team::all();
        $standings = [];

        foreach ($teams as $team) {
            $homeMatches = Match::where('home_team_id', $team->id)->played()->get();
            $awayMatches = Match::where('away_team_id', $team->id)->played()->get();

            $stats = [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'played' => $homeMatches->count() + $awayMatches->count(),
                'won' => 0,
                'drawn' => 0,
                'lost' => 0,
                'goals_for' => 0,
                'goals_against' => 0,
                'goal_difference' => 0,
                'points' => 0,
            ];

            // Calculate home match stats
            foreach ($homeMatches as $match) {
                $stats['goals_for'] += $match->home_score;
                $stats['goals_against'] += $match->away_score;

                if ($match->home_score > $match->away_score) {
                    $stats['won']++;
                    $stats['points'] += 3;
                } elseif ($match->home_score == $match->away_score) {
                    $stats['drawn']++;
                    $stats['points'] += 1;
                } else {
                    $stats['lost']++;
                }
            }

            // Calculate away match stats
            foreach ($awayMatches as $match) {
                $stats['goals_for'] += $match->away_score;
                $stats['goals_against'] += $match->home_score;

                if ($match->away_score > $match->home_score) {
                    $stats['won']++;
                    $stats['points'] += 3;
                } elseif ($match->away_score == $match->home_score) {
                    $stats['drawn']++;
                    $stats['points'] += 1;
                } else {
                    $stats['lost']++;
                }
            }

            $stats['goal_difference'] = $stats['goals_for'] - $stats['goals_against'];
            $standings[] = $stats;
        }

        // Sort by points (desc), then goal difference (desc), then goals for (desc)
        usort($standings, function ($a, $b) {
            if ($a['points'] != $b['points']) {
                return $b['points'] - $a['points'];
            }
            if ($a['goal_difference'] != $b['goal_difference']) {
                return $b['goal_difference'] - $a['goal_difference'];
            }
            return $b['goals_for'] - $a['goals_for'];
        });

        return response()->json($standings);
    }
}