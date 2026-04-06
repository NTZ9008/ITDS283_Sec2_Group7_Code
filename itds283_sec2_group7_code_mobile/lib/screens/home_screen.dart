import 'package:flutter/material.dart';
import 'package:itds283_sec2_group7_code_mobile/routes/app_routes.dart';
import 'package:remixicon/remixicon.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/product_card.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/library_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  int _selectedCategoryIndex = 0;
  List<Map<String, dynamic>> _allBooks = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Remix.function_line, 'name': 'Math'},
    {'icon': Remix.microscope_line, 'name': 'Science'},
    {'icon': Remix.book_read_line, 'name': 'English'},
    {'icon': Remix.leaf_line, 'name': 'Bio'},
    {'icon': Remix.test_tube_line, 'name': 'Chemi'},
    {'icon': Remix.atom_line, 'name': 'Physics'},
    {'icon': Remix.money_dollar_circle_line, 'name': 'Finance'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBooks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = AuthProviderWidget.of(context);
      if (auth.isLoggedIn) {
        LibraryProviderWidget.of(context).fetchLibrary();
        CartProviderWidget.of(context).fetchCart();
      }
    });
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/books'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['books'] ?? data['data'] ?? []);
        setState(() {
          _allBooks = list.map((e) {
            String imageUrl = e['imageUrl'] ?? e['image'] ?? '';
            if (imageUrl.startsWith('/uploads/')) {
              imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
            }
            return {...Map<String, dynamic>.from(e), 'imageUrl': imageUrl};
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBooks {
    final name = _categories[_selectedCategoryIndex]['name'];
    return _allBooks.where((b) => b['category'] == name).toList();
  }

  List<Map<String, dynamic>> get _bestSellers {
    return _allBooks.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildBanner(),
              _buildSectionTitle('Categories'),
              _buildCategories(),
              _buildSectionTitle('Best Seller'),
              _buildBestSeller(),
              _buildSectionTitle('New Collection'),
              _buildNewCollection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D13B),
                ),
              ),
              Text(
                'Ready to learn something new today?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00D13B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Remix.search_line, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=600&auto=format&fit=crop',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'PROMO',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Special Offer\nGet 20% Off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00D13B),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF006B3F)
                          : const Color(0xFF00D13B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF00D13B).withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF006B3F)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestSeller() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF00D13B)),
        ),
      );
    }

    if (_bestSellers.isEmpty) return const SizedBox.shrink();

    final topBook = _bestSellers.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: {
            'title': topBook['title'] ?? '',
            'author': topBook['author'] ?? '',
            'description': topBook['description'] ?? '',
            'price':
                (topBook['price'] is String
                    ? double.tryParse(topBook['price'])
                    : topBook['price']?.toDouble()) ??
                0.0,
            'imageUrl': topBook['imageUrl'] ?? '',
            'bookId': topBook['id'],
          },
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFA5D6A7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topBook['title'] ?? 'Unknown Book',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topBook['author'] ?? 'Unknown Author',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // ฝั่งขวา: โชว์หน้าปกหนังสืออันดับ 1
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 200,
                  height: 110,
                  color: Colors.white,
                  child: Image.network(
                    topBook['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Remix.book_read_line,
                      color: Color(0xFF5B9BD5),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewCollection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF00D13B)),
        ),
      );
    }

    final displayProducts = _filteredBooks;

    if (displayProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'No books in this category yet.',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final book = displayProducts[index];
          return ProductCard(
            title: book['title'] ?? '',
            author: book['author'] ?? '',
            description: book['description'] ?? '',
            price:
                (book['price'] is String
                    ? double.tryParse(book['price'])
                    : book['price']?.toDouble()) ??
                0.0,
            imageUrl: book['imageUrl'] ?? '',
            bookId: book['id'],
            index: index,
          );
        },
      ),
    );
  }
}
