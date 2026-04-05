import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';


class ProductItem {
  final int? id;
  String title;
  String author;
  String category;
  String description;
  double price;
  String imageUrl;
  String pdfUrl; // ✅ เพิ่ม

  ProductItem({
    this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.price,
    this.imageUrl = '',
    this.pdfUrl = '', // ✅ เพิ่ม
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://ebookapi.arlifzs.site';

    String imageUrl = json['imageUrl'] ?? json['image'] ?? json['image_url'] ?? '';
    if (imageUrl.startsWith('/uploads/')) imageUrl = '$baseUrl$imageUrl';

    String pdfUrl = json['pdfUrl'] ?? ''; // ✅ เพิ่ม
    if (pdfUrl.startsWith('/uploads/')) pdfUrl = '$baseUrl$pdfUrl'; // ✅ เพิ่ม

    return ProductItem(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is String
              ? double.tryParse(json['price'])
              : json['price']?.toDouble()) ??
          0.0,
      imageUrl: imageUrl,
      pdfUrl: pdfUrl, // ✅ เพิ่ม
    );
  }
}

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  List<ProductItem> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyBooks();
  }

  Future<String?> _getSellerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('seller_token') ?? prefs.getString('token');
  }

  Future<void> _fetchMyBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getSellerToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/books/seller/my-books'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['books'] ?? data['data'] ?? []);
        for (var item in list) {
          print('imageUrl from API: ${item['imageUrl']}');
        }
        setState(() {
          _products = list.map((e) => ProductItem.fromJson(e)).toList();
        });
        for (var p in _products) {
          print('Final imageUrl: ${p.imageUrl}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(int index) async {
    final product = _products[index];
    if (product.id == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(index, product.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int index, int bookId) async {
    try {
      final token = await _getSellerToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/books/$bookId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => _products.removeAt(index));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบหนังสือสำเร็จ'),
              backgroundColor: Color(0xFF00D13B),
            ),
          );
        }
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบไม่สำเร็จ กรุณาลองใหม่'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            Expanded(child: _buildBody()),
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
            // AddProductScreen ส่ง API เองแล้ว → reload จาก server
            await _fetchMyBooks();
          }
        },
        backgroundColor: const Color(0xFF006B3F),
        child: const Icon(Icons.add, color: Colors.white),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.black26),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchMyBooks,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'ลองใหม่',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D13B),
              ),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      color: const Color(0xFF00D13B),
      onRefresh: _fetchMyBooks,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _products.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) => _buildProductRow(index),
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
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black87,
            ),
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
          Text(
            'No products yet',
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFB2EEF4),
              borderRadius: BorderRadius.circular(8),
            ),
            // _buildProductRow ใน my_products_screen.dart
child: product.imageUrl.isNotEmpty
    ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _bookIcon(),
        ),
      )
    : _bookIcon(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '฿${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF00D13B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<ProductItem>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );
              if (result != null) {
                // EditProductScreen ส่ง API เองแล้ว → reload
                await _fetchMyBooks();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, size: 20, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _deleteProduct(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.delete, size: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookIcon() {
    return const Icon(
      Icons.menu_book_rounded,
      color: Color(0xFF5B9BD5),
      size: 32,
    );
  }
}
