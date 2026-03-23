import 'package:flutter/material.dart';
import '../widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'Finance',
    'Math',
    'Science',
    'English',
    'Bio',
    'Chemi',
    'Physics',
  ];

  final List<Map<String, dynamic>> mockProducts = const [
    {
      'id': 1,
      'title': 'A ',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'id': 2,
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'id': 3,
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
    {
      'id': 4,
      'title': 'Aaaaa Aaaa',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
      'price': 120.00,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
    },
  ];

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
            Expanded(child: _buildProductGrid()),
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
          children: List.generate(categories.length, (index) {
            final isSelected = index == _selectedCategoryIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      width: index == categories.length - 1 ? 0 : 1,
                    ),
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.50,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: mockProducts.length,
      itemBuilder: (context, index) {
        final product = mockProducts[index];
        return ProductCard(
          title: product['title'] ?? '',
          description: product['description'] ?? '',
          price: product['price'] ?? 0.0,
          imageUrl: product['imageUrl'] ?? '',
          index: index,
        );
      },
    );
  }
}