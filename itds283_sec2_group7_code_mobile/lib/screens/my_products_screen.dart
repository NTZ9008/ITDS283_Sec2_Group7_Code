import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductItem {
  String title;
  String author;
  String category;
  String description;
  double price;
  String imageUrl;

  ProductItem({
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.price,
    this.imageUrl = '',
  });
}

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final List<ProductItem> _products = [
    ProductItem(
      title: 'BOOK AAA',
      author: 'Author A',
      category: 'Finance',
      description: 'Lorem ipsum dolor sit amet.',
      price: 120.00,
    ),
    ProductItem(
      title: 'BOOK AAA',
      author: 'Author B',
      category: 'Math',
      description: 'Lorem ipsum dolor sit amet.',
      price: 120.00,
    ),
    ProductItem(
      title: 'BOOK AAA',
      author: 'Author C',
      category: 'Science',
      description: 'Lorem ipsum dolor sit amet.',
      price: 120.00,
    ),
  ];

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _products.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            Expanded(
              child: _products.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) =>
                          _buildProductRow(index),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<ProductItem>(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result != null) {
            setState(() => _products.add(result));
          }
        },
        backgroundColor: const Color(0xFF006B3F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            'My Products',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D13B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text('No products yet',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildProductRow(int index) {
    final product = _products[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Book thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFB2EEF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _bookIcon()),
                  )
                : _bookIcon(),
          ),
          const SizedBox(width: 14),

          // Title + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Color(0xFF00D13B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<ProductItem>(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        EditProductScreen(product: product)),
              );
              if (result != null) {
                setState(() => _products[index] = result);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit,
                  size: 20, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 4),

          // Delete button
          GestureDetector(
            onTap: () => _deleteProduct(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.delete,
                  size: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookIcon() {
    return const Icon(Icons.menu_book_rounded,
        color: Color(0xFF5B9BD5), size: 32);
  }
}