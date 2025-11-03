<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

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

    public function homeTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function isPlayed(): bool
    {
        return $this->home_score !== null && $this->away_score !== null;
    }

    public function scopePlayed(Builder $query): Builder
    {
        return $query->whereNotNull('home_score')->whereNotNull('away_score');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->whereNull('home_score')->whereNull('away_score');
    }
}
