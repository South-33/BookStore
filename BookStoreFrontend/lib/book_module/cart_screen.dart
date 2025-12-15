import 'package:flutter/material.dart';
import 'google_books_model.dart';
import 'purchased_book_service.dart';

class CartScreen extends StatefulWidget {
  final List<GoogleBook> cartItems;
  
  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<GoogleBook> _items;
  final _purchasedBookService = PurchasedBookService();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.cartItems);
  }

  double _getTotal() {
    double total = 0;
    for (var book in _items) {
      if (book.saleInfo?.listPrice != null) {
        total += book.saleInfo!.listPrice!.amount;
      }
    }
    return total;
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
          onPressed: () => Navigator.pop(context, _items),
        ),
        title: Text("My Cart", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _items.isEmpty ? _buildEmptyCart() : _buildCartList(),
      bottomNavigationBar: _items.isEmpty ? null : _buildCheckout(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text("Your cart is empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text("Add some books to get started!", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildCartItem(_items[index], index);
      },
    );
  }

  Widget _buildCartItem(GoogleBook book, int index) {
    String imageUrl = book.volumeInfo.thumbnail.replaceFirst("http:", "https:");
    double price = book.saleInfo?.listPrice?.amount ?? 0;

    return Container(
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
            child: Image.network(imageUrl, width: 60, height: 85, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 60, height: 85, color: Colors.grey[200], child: Icon(Icons.book, color: Colors.grey[400])),
            ),
          ),
          SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.volumeInfo.title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4),
                Text(book.volumeInfo.authors.first, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                SizedBox(height: 8),
                Text(price > 0 ? "\$${price.toStringAsFixed(2)}" : "Free", style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // Remove button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
            onPressed: () {
              setState(() { _items.removeAt(index); });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed from cart"), duration: Duration(seconds: 1)));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckout() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                SizedBox(height: 4),
                Text("\$${_getTotal().toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save purchases to backend
                    final success = await _purchasedBookService.purchaseBooks(_items);
                    
                    if (success) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Order Placed! 🎉"),
                            content: Text("Thank you for your purchase! Your books have been added to your library."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog
                                  setState(() { _items.clear(); });
                                },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to complete purchase. Please try again.")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFe94560),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
