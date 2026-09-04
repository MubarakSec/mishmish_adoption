<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kitten;

class KittenController extends Controller
{
    public function index()
    {
        return response()->json(Kitten::all());
    }

    public function show($id)
    {
        $kitten = Kitten::find($id);
        if (!$kitten) {
            return response()->json(['message' => 'القط غير موجود'], 404);
        }
        return response()->json($kitten);
    }
}
