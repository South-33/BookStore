<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PurchasedBook;
use Illuminate\Http\Request;

class PurchasedBookController extends Controller
{
    public function index(Request $request)
    {
        $books = $request->user()->purchasedBooks()->latest()->get();
        return response()->json($books);
    }

    public function store(Request $request)
    {
        $request->validate([
            'books' => 'required|array',
            'books.*.google_book_id' => 'required|string',
            'books.*.title' => 'required|string',
            'books.*.authors' => 'required|array',
            'books.*.thumbnail' => 'nullable|string',
            'books.*.price' => 'required|numeric',
        ]);

        $purchasedBooks = [];
        foreach ($request->books as $bookData) {
            $purchasedBooks[] = $request->user()->purchasedBooks()->create($bookData);
        }

        return response()->json([
            'message' => 'Books purchased successfully',
            'books' => $purchasedBooks
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'rating' => 'nullable|integer|min:1|max:5',
            'notes' => 'nullable|string',
            'status' => 'nullable|string|in:to-read,reading,completed',
        ]);

        $book = $request->user()->purchasedBooks()->findOrFail($id);
        $book->update($request->only(['rating', 'notes', 'status']));

        return response()->json([
            'message' => 'Book updated successfully',
            'book' => $book
        ]);
    }
}
