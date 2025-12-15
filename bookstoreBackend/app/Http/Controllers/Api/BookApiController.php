<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\Request;

class BookApiController extends Controller
{
    // get all books
    public function index(Request $request)
    {
        $query = Book::query();
        if ($request->filled('search')) {
            $search = strtolower($request->input('search'));
            $keywords = explode(' ', $search);
            $query->where(function ($q) use ($keywords) {
                foreach ($keywords as $word) {
                    $q->whereRaw('LOWER(title) LIKE ?', ["%{$word}%"]);
                }
            });
        }
        $books = $query->latest()->paginate(10);
        return $books;
    }

    // create new book
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'author' => 'required|string',
            'year' => 'required|integer',
        ]);
        $book = Book::create($validated);
        return response()->json($book, 201);
    }

    // get single book
    public function show($id)
    {
        $book = Book::find($id);
        if (!$book) return response()->json(['message' => 'Not found'], 404);
        return $book;
    }

    // update book
    public function update(Request $request, $id)
    {
        $book = Book::find($id);
        if (!$book) return response()->json(['message' => 'Not found'], 404);
        $validated = $request->validate([
            'title' => 'required|string',
            'author' => 'required|string',
            'year' => 'required|integer',
        ]);
        $book->update($validated);
        return response()->json($book);
    }

    // delete book
    public function destroy($id)
    {
        $book = Book::find($id);
        if (!$book) return response()->json(['message' => 'Not found'], 404);
        $book->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
