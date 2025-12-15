import 'package:flutter/material.dart';
import 'google_books_model.dart';

class BookDetailScreen extends StatelessWidget {
  final GoogleBook book;
  final Function(GoogleBook)? onAddToCart;

  const BookDetailScreen({super.key, required this.book, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    String imageUrl = book.volumeInfo.thumbnail.replaceFirst("http:", "https:");
    bool hasPrice = book.saleInfo?.listPrice != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App bar with book cover
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.black87, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Added to favorites!"), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Color(0xFFfce4ec),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 60),
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(imageUrl, height: 220, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 150, height: 220, color: Colors.grey[300],
                          child: Icon(Icons.book, size: 60, color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(book.volumeInfo.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("by ${book.volumeInfo.authors.join(", ")}", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  SizedBox(height: 24),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(Icons.star, book.volumeInfo.averageRating > 0 ? "${book.volumeInfo.averageRating}" : "N/A", "Rating", Colors.amber),
                      _buildDivider(),
                      _buildStat(Icons.menu_book, book.volumeInfo.pageCount > 0 ? "${book.volumeInfo.pageCount}" : "N/A", "Pages", Color(0xFF4facfe)),
                      _buildDivider(),
                      _buildStat(Icons.calendar_today, book.volumeInfo.publishedDate.isNotEmpty ? book.volumeInfo.publishedDate.split("-")[0] : "N/A", "Year", Color(0xFFa18cd1)),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Price tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFe94560).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer, color: Color(0xFFe94560), size: 18),
                        SizedBox(width: 8),
                        Text(
                          hasPrice ? "\$${book.saleInfo!.listPrice!.amount.toStringAsFixed(2)}" : "FREE",
                          style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Description
                  Text("About this book", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(book.volumeInfo.description, style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15)),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Favorite button
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.grey[600]),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Added to wishlist!"), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (onAddToCart != null) {
                        onAddToCart!(book);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to cart!"), backgroundColor: Color(0xFFe94560)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFe94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(Icons.shopping_cart_outlined),
                    label: Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: Colors.grey[200]);
  }
}
