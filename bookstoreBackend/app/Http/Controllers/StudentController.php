<?php

namespace App\Http\Controllers;

use App\Models\Student;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    public function showStudent(){
        // return "hello student in showStudent";
        // return view('sample');
        
        $students = Student::all();
        return $students;
    }
}
