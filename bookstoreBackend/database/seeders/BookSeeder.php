<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Book;

class BookSeeder extends Seeder
{
    public function run(): void
    {
        // sample books data
        $books = [
            ['title' => 'Harry Potter', 'author' => 'J.K. Rowling', 'year' => 1997],
            ['title' => 'The Hobbit', 'author' => 'J.R.R. Tolkien', 'year' => 1937],
            ['title' => '1984', 'author' => 'George Orwell', 'year' => 1949],
            ['title' => 'To Kill a Mockingbird', 'author' => 'Harper Lee', 'year' => 1960],
            ['title' => 'The Great Gatsby', 'author' => 'F. Scott Fitzgerald', 'year' => 1925],
        ];

        foreach ($books as $book) {
            Book::create($book);
        }
    }
}
