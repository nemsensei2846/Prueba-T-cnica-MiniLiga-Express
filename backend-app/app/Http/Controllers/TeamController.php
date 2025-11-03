<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class TeamController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $teams = Team::query()
            ->orderBy('name')
            ->get();

        return response()->json($teams);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:100', 'unique:teams,name'],
            'city' => ['nullable', 'string', 'max:100'],
        ]);

        $team = Team::create($validated);
        return response()->json($team, 201);
    }

    public function show(Team $team): JsonResponse
    {
        return response()->json($team);
    }

    public function update(Request $request, Team $team): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:100', Rule::unique('teams', 'name')->ignore($team->id)],
            'city' => ['nullable', 'string', 'max:100'],
        ]);

        $team->update($validated);
        return response()->json($team);
    }

    public function destroy(Team $team): JsonResponse
    {
        $team->delete();
        return response()->json(null, 204);
    }
}