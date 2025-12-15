# BookStore App - Project Summary

A full-stack mobile book store application with integrated reading tracker. Built with Flutter and Laravel.

## Overview

**What it does:** Browse and purchase real books from Google's database, then track your reading progress with ratings, notes, and status updates.

**Tech Stack:** Flutter (Dart) + Laravel (PHP) + MySQL + Google Books API

**Project Type:** Full-stack mobile application demonstrating authentication, API integration, and CRUD operations

---

## Core Features

### 1. User Authentication
- User registration with validation
- Secure login using token-based authentication (Laravel Sanctum)
- Password hashing with bcrypt
- Persistent login sessions
- Logout functionality

### 2. Book Store
- Browse thousands of real books via Google Books API
- Featured book carousel
- Category filtering (Fiction, Science, History, Romance, etc.)
- Search functionality
- Book details with cover, author, description, and price
- Best Sellers and New Releases sections

### 3. Shopping Cart & Checkout
- Add/remove books from cart
- View cart with item count and total price
- Checkout saves purchases to database
- Purchase confirmation

### 4. Reading Tracker
- View all purchased books in profile
- Rate books with 5-star system
- Set reading status (To Read, Reading, Completed)
- Add personal notes about each book
- Visual status badges and star ratings on book list

---

## Technical Implementation

### Architecture

```
Flutter App (Frontend)
    ↓
    ├─→ Google Books API (Book data)
    └─→ Laravel API (Backend)
            ↓
        MySQL Database
```

### Frontend (Flutter)

**Screens Built:**
- Login & Registration
- Store (main browsing)
- Book Detail
- Shopping Cart
- Profile
- Book Tracking Editor

**Key Services:**
- `BookService` - User authentication
- `GoogleBooksService` - Fetch books from Google API
- `PurchasedBookService` - Manage purchased books and tracking

**State Management:** Provider pattern with FlutterSecureStorage for auth tokens

### Backend (Laravel)

**API Endpoints:**
```
Public:
POST /api/register        - Create account
POST /api/login           - Login & get token

Protected (require auth token):
POST /api/logout          - Invalidate token
GET  /api/purchased-books - Get user's library
POST /api/purchased-books - Save purchase
PUT  /api/purchased-books/{id} - Update tracking
```

**Database Schema:**

**users**
- id, name, email, password (hashed), timestamps

**purchased_books**
- id, user_id (FK), google_book_id, title, authors (JSON), thumbnail, price, rating (1-5), notes, status (to-read/reading/completed), timestamps

---

## How It Works

### User Flow

1. **Register/Login** → User creates account or logs in → Receives auth token → Token stored securely on device

2. **Browse Books** → Flutter fetches books from Google Books API → Displays in categorized lists with search

3. **Add to Cart** → Books stored in local app state → Cart icon shows item count

4. **Checkout** → Flutter sends cart data to Laravel API → Books saved to MySQL `purchased_books` table → Linked to user's account

5. **Track Reading** → User opens profile → Sees purchased books → Taps book to edit → Can rate, add notes, set status → Changes saved to database

6. **Logout** → Token invalidated on server → User redirected to login

### Authentication Flow

```
Login Request
    ↓
Laravel validates credentials
    ↓
Generate Sanctum token
    ↓
Return token to Flutter
    ↓
Flutter stores in encrypted storage
    ↓
All future API calls include: Authorization: Bearer {token}
```

---

## Tech Stack Rationale

**Flutter (Dart)**
- Cross-platform: Write once, run on Android, iOS, Windows, Web
- Fast development with hot reload
- Rich widget library for modern UI

**Laravel (PHP)**
- Straightforward REST API creation
- Built-in Sanctum for token authentication
- Eloquent ORM for database operations
- Strong validation system

**MySQL**
- Relational database perfect for user-book relationships
- Reliable and well-documented
- Wide hosting support

**Google Books API**
- Free access to millions of books
- Provides covers, descriptions, authors, ratings
- No API key needed for basic searches

---

## Key Technical Decisions

1. **Token-based Auth** - Stateless, scalable, secure for mobile apps
2. **FlutterSecureStorage** - Encrypted token storage on device
3. **Provider Pattern** - Simple state management for small-medium apps
4. **JSON for Authors** - Flexible storage for variable number of authors
5. **Google Books Integration** - Real data without maintaining book database

---

## Setup & Running

### Backend
```bash
cd bookstore
composer install
php artisan migrate
php artisan serve  # http://127.0.0.1:8000
```

### Frontend
```bash
cd BookStore
flutter pub get
flutter run -d windows  # or -d chrome, or for mobile
```

---

## Project Structure

```
BookStore/
├── lib/book_module/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── store_screen.dart
│   ├── cart_screen.dart
│   ├── profile_screen.dart
│   ├── purchased_book_detail_screen.dart
│   └── *_service.dart (API services)
└── main.dart

bookstore/ (Laravel)
├── app/
│   ├── Models/
│   │   ├── User.php
│   │   └── PurchasedBook.php
│   └── Http/Controllers/Api/
│       ├── AuthController.php
│       └── PurchasedBookController.php
├── database/migrations/
└── routes/api.php
```

---

## Challenges & Solutions

**Challenge:** Securing auth tokens on device  
**Solution:** FlutterSecureStorage with encryption

**Challenge:** Parsing complex Google Books JSON  
**Solution:** Created model classes with `fromJson` methods

**Challenge:** Maintaining auth state across screens  
**Solution:** Provider pattern with centralized user logic

**Challenge:** Sending token with every protected request  
**Solution:** Centralized service classes handle headers automatically

---

## Future Enhancements

- Real payment integration (Stripe/PayPal)
- Social features (share reviews, follow friends)
- Book recommendations based on reading history
- Offline mode with data sync
- Reading statistics and progress visualization

## Notes

- This is a student project for educational purposes
- Demonstrates full-stack development with modern technologies
- Purchase is simulated (no real payment processing)
- All passwords securely hashed, tokens encrypted
- Real book data from Google Books API

## Summary

**What it does:** Users can browse real books from Google Books API, add them to cart, purchase them, and track their reading progress with ratings and notes.

**Tech Stack:** Flutter (frontend), Laravel (backend), MySQL (database), Google Books API

**Key Features:** User authentication, book browsing/search, shopping cart, purchase tracking, reading status & ratings

## Features

- **User Authentication**: Secure registration and login with token-based authentication
- **Book Store**: Browse thousands of real books from Google Books API
- **Shopping Cart**: Add books to cart and checkout
- **Reading Tracker**: Track your reading progress with ratings, status, and notes
- **Profile Management**: View your purchased books and manage account

## Tech Stack

### Frontend
- **Flutter (Dart)** - Cross-platform mobile framework
- **HTTP Package** - API requests
- **Provider** - State management
- **FlutterSecureStorage** - Secure token storage

### Backend
- **Laravel (PHP)** - REST API framework
- **MySQL** - Database
- **Laravel Sanctum** - API authentication

### External API
- **Google Books API** - Real book data

## How It Works

1. **User Registration/Login**: User creates account or logs in, receives authentication token
2. **Browse Books**: App fetches books from Google Books API
3. **Add to Cart**: Books stored in local app state
4. **Checkout**: Books sent to Laravel API and saved in database
5. **Track Reading**: Users can rate, add notes, and update reading status
6. **Profile**: View all purchased books and logout