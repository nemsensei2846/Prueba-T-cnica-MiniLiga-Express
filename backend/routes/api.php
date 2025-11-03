<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\MatchController;
use App\Http\Controllers\StandingsController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Teams routes
Route::apiResource('teams', TeamController::class);

// Matches routes
Route::apiResource('matches', MatchController::class);

// Standings route
Route::get('standings', [StandingsController::class, 'index']);

// Health check
Route::get('health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});
