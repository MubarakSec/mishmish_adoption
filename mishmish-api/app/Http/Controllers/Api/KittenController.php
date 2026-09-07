<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kitten;
use Illuminate\Http\Request;

class KittenController extends Controller
{
    public function index(Request $request)
    {
        $user = auth('sanctum')->user();
        $favIds = $user ? $user->favorites()->pluck('kitten_id')->toArray() : [];

        $kittens = Kitten::all()->map(function ($kitten) use ($favIds) {
            $data = $kitten->toArray();
            $data['is_favorite'] = in_array($kitten->id, $favIds);
            return $data;
        });

        return response()->json($kittens);
    }

    public function show(Request $request, $id)
    {
        $kitten = Kitten::find($id);
        if (!$kitten) {
            return response()->json(['message' => 'القط غير موجود'], 404);
        }

        $user = auth('sanctum')->user();
        $favIds = $user ? $user->favorites()->pluck('kitten_id')->toArray() : [];

        $data = $kitten->toArray();
        $data['is_favorite'] = in_array($kitten->id, $favIds);

        return response()->json($data);
    }
}
