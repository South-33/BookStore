import 'package:flutter/material.dart';
import 'purchased_book_service.dart';

class PurchasedBookDetailScreen extends StatefulWidget {
  final dynamic book;
  
  const PurchasedBookDetailScreen({super.key, required this.book});

  @override
  State<PurchasedBookDetailScreen> createState() => _PurchasedBookDetailScreenState();
}

class _PurchasedBookDetailScreenState extends State<PurchasedBookDetailScreen> {
  final _service = PurchasedBookService();
  final _notesController = TextEditingController();
  
  int _rating = 0;
  String _status = 'to-read';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.book['rating'] ?? 0;
    _status = widget.book['status'] ?? 'to-read';
    _notesController.text = widget.book['notes'] ?? '';
  }

  Future<void> _saveChanges() async {
    setState(() { _isSaving = true; });
    
    final success = await _service.updatePurchasedBook(
      widget.book['id'],
      rating: _rating > 0 ? _rating : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      status: _status,
    );

    setState(() { _isSaving = false; });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.book['title'] ?? '';
    List<dynamic> authorsRaw = widget.book['authors'] ?? [];
    List<String> authors = authorsRaw.map((a) => a.toString()).toList();
    String? thumbnail = widget.book['thumbnail'];
    double price = double.tryParse(widget.book['price'].toString()) ?? 0.0;
    String imageUrl = thumbnail?.replaceFirst("http:", "https:") ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Track Book", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(imageUrl, title, authors, price),
            SizedBox(height: 20),
            _buildStatusSection(),
            SizedBox(height: 20),
            _buildRatingSection(),
            SizedBox(height: 20),
            _buildNotesSection(),
            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildBookHeader(String imageUrl, String title, List<String> authors, double price) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, width: 80, height: 120, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 80, height: 120, color: Colors.grey[200], child: Icon(Icons.book, color: Colors.grey[400])))
                : Container(width: 80, height: 120, color: Colors.grey[200], child: Icon(Icons.book, color: Colors.grey[400])),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 3),
                SizedBox(height: 6),
                Text(authors.join(", "), style: TextStyle(color: Colors.grey[600]), maxLines: 2),
                SizedBox(height: 8),
                Text(price > 0 ? "\$${price.toStringAsFixed(2)}" : "Free", style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Reading Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip('to-read', 'To Read'),
              SizedBox(width: 8),
              _buildStatusChip('reading', 'Reading'),
              SizedBox(width: 8),
              _buildStatusChip('completed', 'Done'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String value, String label) {
    bool isSelected = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _status = value; }),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFe94560) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() { _rating = index + 1; }),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Color(0xFFe94560),
                  size: 40,
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            SizedBox(height: 8),
            Center(child: Text("${_rating} out of 5 stars", style: TextStyle(color: Colors.grey[600]))),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "What did you think about this book?",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFe94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
