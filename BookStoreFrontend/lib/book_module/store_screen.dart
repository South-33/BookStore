import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'google_books_model.dart';
import 'google_books_service.dart';
import 'book_detail_screen.dart';
import 'book_service.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _googleBooksService = GoogleBooksService();
  final _bookService = BookService();
  final _searchCtrl = TextEditingController();
  
  Future<GoogleBooksResponse>? _featuredBooks;
  Future<GoogleBooksResponse>? _bestSellers;
  Future<GoogleBooksResponse>? _newReleases;
  Future<GoogleBooksResponse>? _searchResults;
  
  bool _isSearchMode = false;
  List<GoogleBook> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    _featuredBooks = _googleBooksService.searchBooks("popular fiction 2024");
    _bestSellers = _googleBooksService.searchBooks("bestseller");
    _newReleases = _googleBooksService.searchBooks("new releases books");
  }

  void _searchBooks(String query) {
    if (query.trim().isEmpty) {
      setState(() { _isSearchMode = false; });
    } else {
      _searchResults = _googleBooksService.searchBooks(query);
      setState(() { _isSearchMode = true; });
    }
  }

  void _addToCart(GoogleBook book) {
    setState(() { _cartItems.add(book); });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added to cart!"), duration: Duration(seconds: 1), backgroundColor: Color(0xFFe94560)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isSearchMode ? _buildSearchResults() : _buildHome(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFe94560),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_book, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                "BookStore",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e)),
              ),
            ],
          ),
          Row(
            children: [
              // Cart button with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (c) => CartScreen(cartItems: _cartItems)),
                      );
                      if (result != null) {
                        setState(() { _cartItems = result; });
                      }
                    },
                    icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey[700]),
                  ),
                  if (_cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Color(0xFFe94560), shape: BoxShape.circle),
                        child: Text("${_cartItems.length}", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (c) => ProfileScreen()),
                  );
                },
                icon: Icon(Icons.person_outline, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: "Search for books...",
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() { _isSearchMode = false; });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: _searchBooks,
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      color: Color(0xFFe94560),
      onRefresh: () async {
        _loadBooks();
        setState(() {});
      },
      child: ListView(
        children: [
          _buildFeaturedSection(),
          _buildCategoryChips(),
          _buildSection("🔥 Best Sellers", _bestSellers),
          _buildSection("✨ New Releases", _newReleases),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return FutureBuilder<GoogleBooksResponse>(
      future: _featuredBooks,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
          return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFe94560))));
        }

        GoogleBook featured = snapshot.data!.items[0];
        String imageUrl = featured.volumeInfo.thumbnail.replaceFirst("http:", "https:");

        return Container(
          margin: EdgeInsets.all(20),
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFe94560), Color(0xFFff6b6b)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Color(0xFFe94560).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
          ),
          child: InkWell(
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (c) => BookDetailScreen(book: featured, onAddToCart: _addToCart))),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                          child: Text("Featured", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(height: 12),
                        Text(featured.volumeInfo.title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 6),
                        Text(featured.volumeInfo.authors.join(", "), style: TextStyle(color: Colors.white70, fontSize: 13), maxLines: 1),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Text("View Book", style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl, fit: BoxFit.cover, height: 150,
                      errorBuilder: (c, e, s) => Container(color: Colors.white24, child: Icon(Icons.book, color: Colors.white38, size: 40)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    List<Map<String, dynamic>> categories = [
      {"name": "Fiction", "color": Color(0xFFe94560)},
      {"name": "Science", "color": Color(0xFF4facfe)},
      {"name": "History", "color": Color(0xFFf093fb)},
      {"name": "Romance", "color": Color(0xFFff6b6b)},
      {"name": "Mystery", "color": Color(0xFF667eea)},
      {"name": "Fantasy", "color": Color(0xFFa18cd1)},
    ];

    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _searchCtrl.text = categories[index]["name"];
                _searchBooks(categories[index]["name"]);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: categories[index]["color"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categories[index]["color"].withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(categories[index]["name"], style: TextStyle(color: categories[index]["color"], fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<GoogleBooksResponse>? future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 290,
          child: FutureBuilder<GoogleBooksResponse>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(color: Color(0xFFe94560)));
              }
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.items.length.clamp(0, 10),
                  itemBuilder: (context, index) => _buildBookCard(snapshot.data!.items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(GoogleBook book) {
    String imageUrl = book.volumeInfo.thumbnail.replaceFirst("http:", "https:");
    bool hasPrice = book.saleInfo?.listPrice != null;

    return GestureDetector(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (c) => BookDetailScreen(book: book, onAddToCart: _addToCart))),
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                  errorBuilder: (c, e, s) => Center(child: Icon(Icons.book, color: Colors.grey[400], size: 40)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.volumeInfo.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(book.volumeInfo.authors.first, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hasPrice ? "\$${book.saleInfo!.listPrice!.amount.toStringAsFixed(0)}" : "Free",
                        style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold, fontSize: 14)),
                      if (book.volumeInfo.averageRating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(" ${book.volumeInfo.averageRating}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<GoogleBooksResponse>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Color(0xFFe94560)));
        }
        if (snapshot.data!.items.isEmpty) {
          return Center(child: Text("No books found", style: TextStyle(color: Colors.grey[600])));
        }
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.58, crossAxisSpacing: 16, mainAxisSpacing: 16),
          itemCount: snapshot.data!.items.length,
          itemBuilder: (context, index) => _buildGridBookCard(snapshot.data!.items[index]),
        );
      },
    );
  }

  Widget _buildGridBookCard(GoogleBook book) {
    String imageUrl = book.volumeInfo.thumbnail.replaceFirst("http:", "https:");
    bool hasPrice = book.saleInfo?.listPrice != null;

    return GestureDetector(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (c) => BookDetailScreen(book: book, onAddToCart: _addToCart))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: Icon(Icons.book, color: Colors.grey[400], size: 40)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.volumeInfo.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text(book.volumeInfo.authors.first, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1),
                    Spacer(),
                    Text(hasPrice ? "\$${book.saleInfo!.listPrice!.amount.toStringAsFixed(2)}" : "Free",
                      style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
