<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class Team extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'city',
    ];

    public function homeMatches(): HasMany
    {
        return $this->hasMany(Match::class, 'home_team_id');
    }

    public function awayMatches(): HasMany
    {
        return $this->hasMany(Match::class, 'away_team_id');
    }

    public function matches(): HasManyThrough
    {
        return $this->hasManyThrough(
            Match::class,
            Team::class,
            'id',
            'home_team_id'
        )->orWhere('away_team_id', $this->id);
    }
}