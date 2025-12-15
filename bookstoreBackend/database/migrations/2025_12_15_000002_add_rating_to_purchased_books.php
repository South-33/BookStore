<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('purchased_books', function (Blueprint $table) {
            $table->integer('rating')->nullable();
            $table->text('notes')->nullable();
            $table->string('status')->default('to-read');
        });
    }

    public function down(): void
    {
        Schema::table('purchased_books', function (Blueprint $table) {
            $table->dropColumn(['rating', 'notes', 'status']);
        });
    }
};
