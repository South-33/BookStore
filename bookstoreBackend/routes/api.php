<?php

use App\Http\Controllers\Api\BookApiController;
use App\Http\Controllers\Api\PurchasedBookController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

// Protect the books routes
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('/books', BookApiController::class);
    Route::get('/purchased-books', [PurchasedBookController::class, 'index']);
    Route::post('/purchased-books', [PurchasedBookController::class, 'store']);
    Route::put('/purchased-books/{id}', [PurchasedBookController::class, 'update']);
});
