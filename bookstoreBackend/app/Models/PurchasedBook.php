<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PurchasedBook extends Model
{
    protected $fillable = [
        'user_id',
        'google_book_id',
        'title',
        'authors',
        'thumbnail',
        'price',
        'rating',
        'notes',
        'status',
    ];

    protected $casts = [
        'authors' => 'array',
        'price' => 'decimal:2',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
