<?php

use App\Http\Controllers\CustomerController;
use App\Http\Controllers\StudentController;
use Database\Factories\CustomerFactory;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});


Route::get('/students', [StudentController::class, 'showStudent']);

Route::get('/customers', [CustomerController::class, 'index']);
