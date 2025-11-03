<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return response()->json([
        'message' => 'Mini Liga Express API',
        'version' => '1.0.0',
        'endpoints' => [
            'GET /api/teams' => 'List all teams',
            'POST /api/teams' => 'Create a new team',
            'GET /api/teams/{id}' => 'Get team details',
            'PUT /api/teams/{id}' => 'Update team',
            'DELETE /api/teams/{id}' => 'Delete team',
            'GET /api/matches' => 'List matches (with ?played=true/false filter)',
            'POST /api/matches' => 'Create a new match',
            'GET /api/matches/{id}' => 'Get match details',
            'PUT /api/matches/{id}' => 'Update match (including scores)',
            'DELETE /api/matches/{id}' => 'Delete match',
            'GET /api/standings' => 'Get league standings',
            'GET /api/health' => 'Health check',
        ]
    ]);
});