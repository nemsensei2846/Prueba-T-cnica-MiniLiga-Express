<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TeamController extends Controller
{
    /**
     * Display a listing of the teams.
     */
    public function index(): JsonResponse
    {
        $teams = Team::all();
        return response()->json($teams);
    }

    /**
     * Store a newly created team in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:teams',
            'city' => 'required|string|max:255',
        ]);

        $team = Team::create([
            'name' => $request->name,
            'city' => $request->city,
        ]);

        return response()->json($team, 201);
    }

    /**
     * Display the specified team.
     */
    public function show(Team $team): JsonResponse
    {
        return response()->json($team);
    }

    /**
     * Update the specified team in storage.
     */
    public function update(Request $request, Team $team): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:teams,name,' . $team->id,
            'city' => 'sometimes|required|string|max:255',
        ]);

        $team->update($request->only(['name', 'city']));

        return response()->json($team);
    }

    /**
     * Remove the specified team from storage.
     */
    public function destroy(Team $team): JsonResponse
    {
        $team->delete();
        return response()->json(null, 204);
    }
}