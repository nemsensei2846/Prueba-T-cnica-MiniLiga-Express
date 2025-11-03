<?php

namespace App\Http\Controllers;

use App\Models\Match;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MatchController extends Controller
{
    /**
     * Display a listing of matches.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Match::with(['homeTeam', 'awayTeam']);

        // Filter by played status if requested
        if ($request->has('played')) {
            if ($request->boolean('played')) {
                $query->played();
            } else {
                $query->pending();
            }
        }

        $matches = $query->get();
        return response()->json($matches);
    }

    /**
     * Store a newly created match in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'played_at' => 'nullable|date',
        ]);

        $match = Match::create([
            'home_team_id' => $request->home_team_id,
            'away_team_id' => $request->away_team_id,
            'played_at' => $request->played_at,
        ]);

        return response()->json($match->load(['homeTeam', 'awayTeam']), 201);
    }

    /**
     * Display the specified match.
     */
    public function show(Match $match): JsonResponse
    {
        return response()->json($match->load(['homeTeam', 'awayTeam']));
    }

    /**
     * Update the specified match in storage.
     */
    public function update(Request $request, Match $match): JsonResponse
    {
        $request->validate([
            'home_team_id' => 'sometimes|required|exists:teams,id',
            'away_team_id' => 'sometimes|required|exists:teams,id|different:home_team_id',
            'home_score' => 'nullable|integer|min:0',
            'away_score' => 'nullable|integer|min:0',
            'played_at' => 'nullable|date',
        ]);

        $match->update($request->only([
            'home_team_id', 
            'away_team_id', 
            'home_score', 
            'away_score', 
            'played_at'
        ]));

        return response()->json($match->load(['homeTeam', 'awayTeam']));
    }

    /**
     * Remove the specified match from storage.
     */
    public function destroy(Match $match): JsonResponse
    {
        $match->delete();
        return response()->json(null, 204);
    }
}
