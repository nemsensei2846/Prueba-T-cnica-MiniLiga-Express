<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Match extends Model
{
    use HasFactory;

    protected $fillable = [
        'home_team_id',
        'away_team_id',
        'home_score',
        'away_score',
        'played_at',
    ];

    protected $casts = [
        'played_at' => 'datetime',
    ];

    public function homeTeam()
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam()
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function isPlayed()
    {
        return !is_null($this->home_score) && !is_null($this->away_score);
    }

    public function scopePlayed($query)
    {
        return $query->whereNotNull('home_score')->whereNotNull('away_score');
    }

    public function scopePending($query)
    {
        return $query->whereNull('home_score')->whereNull('away_score');
    }
}
