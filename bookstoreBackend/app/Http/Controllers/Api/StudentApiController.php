<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\Request;

class StudentApiController extends Controller
{
    public function index(Request $request)
    {
        $query = Student::query();
        if ($request->filled('search')) {
            $search = strtolower($request->input('search'));
            $keywords = explode(' ', $search);
            $query->where(function ($q) use ($keywords) {
                foreach ($keywords as $word) {
                    $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"]);
                }
            });
        }
        $students = $query->latest()->paginate(10);
        return $students;
    }

    public function store(Request $request)
    {
        $validated = $request->validate(['name' => 'required|string']);
        $student = Student::create($validated);
        return response()->json($student, 201);
    }

    public function show($id)
    {
        $student = Student::find($id);
        if (!$student) return response()->json(['message' => 'Not found'], 404);
        return $student;
    }

    public function update(Request $request, $id)
    {
        $student = Student::find($id);
        if (!$student) return response()->json(['message' => 'Not found'], 404);
        $validated = $request->validate(['name' => 'required|string']);
        $student->update($validated);
        return response()->json($student);
    }

    public function destroy($id)
    {
        $student = Student::find($id);
        if (!$student) return response()->json(['message' => 'Not found'], 404);
        $student->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
