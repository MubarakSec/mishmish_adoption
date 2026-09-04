<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = Favorite::where('user_id', $request->user()->id)
            ->with('kitten')
            ->get();

        return response()->json($favorites);
    }

    public function toggle(Request $request, $kittenId)
    {
        $existing = Favorite::where('user_id', $request->user()->id)
            ->where('kitten_id', $kittenId)
            ->first();

        if ($existing) {
            $existing->delete();
            return response()->json(['message' => 'تم الإزالة من المفضلة', 'is_favorite' => false]);
        }

        Favorite::create([
            'user_id' => $request->user()->id,
            'kitten_id' => $kittenId,
        ]);

        return response()->json(['message' => 'تمت الإضافة للمفضلة', 'is_favorite' => true]);
    }
}
