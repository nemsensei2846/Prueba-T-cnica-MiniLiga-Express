<?php

namespace App\Http\Controllers;

use App\Models\Match;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class MatchController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status'); // played|pending|null

        $query = Match::query()->with(['homeTeam', 'awayTeam'])->orderByDesc('played_at');

        if ($status === 'played') {
            $query->played();
        } elseif ($status === 'pending') {
            $query->pending();
        }

        return response()->json($query->get());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'home_team_id' => ['required', 'integer', Rule::exists('teams', 'id')],
            'away_team_id' => ['required', 'integer', Rule::exists('teams', 'id'), 'different:home_team_id'],
            'home_score' => ['nullable', 'integer', 'min:0'],
            'away_score' => ['nullable', 'integer', 'min:0'],
            'played_at' => ['nullable', 'date'],
        ]);

        $match = Match::create($validated);
        return response()->json($match->load(['homeTeam', 'awayTeam']), 201);
    }

    public function show(Match $match): JsonResponse
    {
        return response()->json($match->load(['homeTeam', 'awayTeam']));
    }

    public function update(Request $request, Match $match): JsonResponse
    {
        $validated = $request->validate([
            'home_team_id' => ['sometimes', 'required', 'integer', Rule::exists('teams', 'id')],
            'away_team_id' => ['sometimes', 'required', 'integer', Rule::exists('teams', 'id'), 'different:home_team_id'],
            'home_score' => ['nullable', 'integer', 'min:0'],
            'away_score' => ['nullable', 'integer', 'min:0'],
            'played_at' => ['nullable', 'date'],
        ]);

        $match->update($validated);
        return response()->json($match->load(['homeTeam', 'awayTeam']));
    }

    public function destroy(Match $match): JsonResponse
    {
        $match->delete();
        return response()->json(null, 204);
    }
}