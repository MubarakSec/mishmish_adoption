<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KittenController;
use App\Http\Controllers\Api\FavoriteController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/verify-code', [AuthController::class, 'verifyCode']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Public data routes
Route::get('/kittens', [KittenController::class, 'index']);
Route::get('/kittens/{id}', [KittenController::class, 'show']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/{kittenId}', [FavoriteController::class, 'toggle']);
});
