import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedCategoryIndex = 0;
  List<Map<String, dynamic>> _allBooks = [];

  final List<String> _categories = [
    'All',
    'Finance',
    'Math',
    'Science',
    'English',
    'Bio',
    'Chemi',
    'Physics',
  ];

  bool _isLoading = true;
  String? _errorMessage;

  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/books');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> list = data is List
            ? data
            : (data['books'] ?? data['data'] ?? []);

        final books = list.map((e) => Map<String, dynamic>.from(e)).toList();

        setState(() {
          _allBooks = books;
          _isLoading = false;
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBooks {
    final selectedCategory = _categories[_selectedCategoryIndex];
    if (selectedCategory == 'All') return _allBooks;
    return _allBooks.where((b) => b['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF00D13B),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: const Text(
        '67-E Book',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFamily: 'Jua',
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_categories.length, (index) {
            final isSelected = index == _selectedCategoryIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF00D13B)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    right: BorderSide(
                      color: Colors.black12,
                      width: index == _categories.length - 1 ? 0 : 1,
                    ),
                  ),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF00D13B)
                        : Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D13B)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: Colors.black26,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchBooks,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'ลองใหม่',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D13B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildProductGrid();
  }

  Widget _buildProductGrid() {
    final books = _filteredBooks;

    if (books.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีหนังสือในหมวดนี้',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00D13B),
      onRefresh: _fetchBooks,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65, // เปลี่ยนจาก 0.50 เป็น 0.65
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];

          String imageUrl =
              book['imageUrl'] ?? book['image'] ?? book['image_url'] ?? '';
          if (imageUrl.startsWith('/uploads/')) {
            imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
          }

          return ProductCard(
            title: book['title'] ?? '',
            author: book['author'] ?? '', // เพิ่ม
            description: book['description'] ?? '',
            price:
                (book['price'] is String
                    ? double.tryParse(book['price'])
                    : book['price']?.toDouble()) ??
                0.0,
            imageUrl: imageUrl,
            bookId: book['id'],
            index: index,
          );
        },
      ),
    );
  }
}
