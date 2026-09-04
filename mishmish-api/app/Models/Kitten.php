<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kitten extends Model
{
    protected $fillable = ['name', 'breed', 'age', 'description', 'price', 'image_url'];

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}
