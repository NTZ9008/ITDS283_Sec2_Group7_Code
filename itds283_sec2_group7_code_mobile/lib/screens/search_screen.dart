import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _allBooks = [
    {
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
  ];

  // Track favorite state per index
  final Set<int> _favorites = {};

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _allBooks;
    return _allBooks
        .where((b) =>
            (b['title'] as String)
                .toLowerCase()
                .contains(_query.toLowerCase()) ||
            (b['description'] as String)
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? _buildEmpty()
                  : _buildGrid(results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
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
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search Here...',
            hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
            prefixIcon: Icon(Icons.search, color: Colors.black45, size: 22),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Text('No results found',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
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

  Widget _buildCard(
      BuildContext context, int index, Map<String, dynamic> book) {
    final isFav = _favorites.contains(index);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: {
          'title': book['title'],
          'author': 'Unknown Author',
          'description': book['description'],
          'price': book['price'],
          'imageUrl': book['imageUrl'],
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
            // Cover image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFFB2EEF4),
                child: Image.network(
                  book['imageUrl'],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF5B9BD5),
                      size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book['description'],
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(book['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D13B),
                        ),
                      ),
                      Row(
                        children: [
                          // Favorite button
                          GestureDetector(
                            onTap: () => setState(() {
                              if (isFav) {
                                _favorites.remove(index);
                              } else {
                                _favorites.add(index);
                              }
                            }),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006B3F),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Add to cart button
                          GestureDetector(
                            onTap: () {
                              CartProviderWidget.of(context).addItem(
                                title: book['title'],
                                price: book['price'],
                                imageUrl: book['imageUrl'],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added "${book['title']}" to cart'),
                                  backgroundColor: const Color(0xFF00D13B),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006B3F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
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