import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final uri = Uri.parse('$_baseUrl/books?search=${Uri.encodeComponent(query)}');
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list =
            data is List ? data : (data['books'] ?? data['data'] ?? []);

        setState(() {
          _results = list.map((e) {
            String imageUrl = e['imageUrl'] ?? e['image'] ?? '';
            if (imageUrl.startsWith('/uploads/')) {
              imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
            }
            return {
              ...Map<String, dynamic>.from(e),
              'imageUrl': imageUrl,
            };
          }).toList();
        });
      }
    } catch (_) {} 
    finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
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
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.black12),
            SizedBox(height: 12),
            Text('Search for books...', style: TextStyle(color: Colors.black38)),
          ],
        ),
      );
    }
    if (_results.isEmpty) return _buildEmpty();
    return _buildGrid(_results);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            'Search',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00D13B)),
          ),
          const Text(
            'Find books, sheets, and notes.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => _search(v), // ค้นหาทันทีเมื่อพิมพ์
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search Here...',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
            prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _search('');
                    },
                    child: const Icon(Icons.clear, color: Colors.black38, size: 20),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text('No results found', style: TextStyle(fontSize: 16, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> results) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildCard(context, index, results[index]),
    );
  }

  Widget _buildCard(BuildContext context, int index, Map<String, dynamic> book) {
    final isFav = FavoriteProviderWidget.of(context).isFavorite(book['title']);
    final price = (book['price'] is String
            ? double.tryParse(book['price'])
            : book['price']?.toDouble()) ??
        0.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: {
          'title': book['title'],
          'author': book['author'] ?? '',
          'description': book['description'] ?? '',
          'price': price,
          'imageUrl': book['imageUrl'] ?? '',
          'bookId': book['id'],
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFB2EEF4),
                child: Image.network(
                  book['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 60,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book['description'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '฿${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D13B),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              FavoriteProviderWidget.of(context).toggleFavorite(
                                title: book['title'],
                                description: book['description'] ?? '',
                                price: price,
                                imageUrl: book['imageUrl'] ?? '',
                              );
                            },
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006B3F),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              CartProviderWidget.of(context).addItem(
                                title: book['title'],
                                price: price,
                                imageUrl: book['imageUrl'] ?? '',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${book['title']}" to cart'),
                                  backgroundColor: const Color(0xFF00D13B),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: 30, height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006B3F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
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
}