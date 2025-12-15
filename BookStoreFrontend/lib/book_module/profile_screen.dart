import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'purchased_book_service.dart';
import 'purchased_book_detail_screen.dart';
import 'book_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _purchasedBookService = PurchasedBookService();
  final _bookService = BookService();
  List<dynamic> _purchasedBooks = [];
  bool _isLoading = true;
  String _userName = "";
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPurchasedBooks();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "User";
      _userEmail = prefs.getString('user_email') ?? "";
    });
  }

  Future<void> _loadPurchasedBooks() async {
    setState(() { _isLoading = true; });
    try {
      final books = await _purchasedBookService.getPurchasedBooks();
      setState(() {
        _purchasedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load purchased books")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Profile", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(child: _buildPurchasedBooks()),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFe94560), Color(0xFFff6b6b)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(_userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(_userEmail, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _bookService.logout(context),
              icon: Icon(Icons.logout, size: 18),
              label: Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFe94560),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Books", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("${_purchasedBooks.length} books", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Color(0xFFe94560)))
              : _purchasedBooks.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: Color(0xFFe94560),
                      onRefresh: _loadPurchasedBooks,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _purchasedBooks.length,
                        itemBuilder: (context, index) => _buildBookCard(_purchasedBooks[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text("No books purchased yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text("Start shopping to build your library!", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildBookCard(dynamic book) {
    String title = book['title'] ?? '';
    List<dynamic> authorsRaw = book['authors'] ?? [];
    List<String> authors = authorsRaw.map((a) => a.toString()).toList();
    String? thumbnail = book['thumbnail'];
    double price = double.tryParse(book['price'].toString()) ?? 0.0;
    int rating = book['rating'] ?? 0;
    String status = book['status'] ?? 'to-read';
    
    String imageUrl = thumbnail?.replaceFirst("http:", "https:") ?? "";

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(builder: (c) => PurchasedBookDetailScreen(book: book)),
        );
        if (result == true) {
          _loadPurchasedBooks();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: 60, height: 85, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 60, height: 85, color: Colors.grey[200],
                        child: Icon(Icons.book, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      width: 60, height: 85, color: Colors.grey[200],
                      child: Icon(Icons.book, color: Colors.grey[400]),
                    ),
            ),
            SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(authors.join(", "), style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (rating > 0) ...[
                        Row(
                          children: List.generate(rating, (i) => Icon(Icons.star, size: 14, color: Colors.amber)),
                        ),
                        SizedBox(width: 8),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'reading': return Color(0xFF4facfe);
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'reading': return 'Reading';
      case 'completed': return 'Done';
      default: return 'To Read';
    }
  }
}
