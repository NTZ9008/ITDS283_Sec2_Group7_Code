import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final int? id;
  final int? bookId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
  bool selected;

  CartItem({
    this.id,
    this.bookId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.selected = true,
  });
}

class CartProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  List<CartItem> _items = [];
  bool isLoading = false;

  List<CartItem> get items => _items;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('seller_token');
  }

  // GET /cart
  Future<void> fetchCart() async {
  isLoading = true;
  notifyListeners();

  try {
    final token = await _getToken();

    if (token == null) {
      _items = [];
      return;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list =
          data is List ? data : (data['cart'] ?? data['items'] ?? data['data'] ?? []);

      _items = list.map((e) {
        final book = e['book'] ?? e;
        String imageUrl = book['imageUrl'] ?? book['image'] ?? '';
        if (imageUrl.startsWith('/uploads/')) {
          imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
        }
        return CartItem(
          id: e['id'],
          bookId: book['id'] ?? e['bookId'],
          title: book['title'] ?? '',
          price: (book['price'] is String
                  ? double.tryParse(book['price'])
                  : book['price']?.toDouble()) ??
              0.0,
          imageUrl: imageUrl,
          quantity: e['quantity'] ?? 1,
          selected: true,
        );
      }).toList();
    }
  } catch (e) {
    print('fetchCart error: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  // POST /cart/add
  Future<void> addItem({
    required String title,
    required double price,
    required String imageUrl,
    int? bookId,
  }) async {
    final exists = _items.any((item) => item.title == title);
    if (exists) return;

    try {
      final token = await _getToken();
      if (token == null || bookId == null) {
        // ถ้าไม่มี token หรือ bookId ให้เพิ่ม local แทน
        _items.add(CartItem(title: title, price: price, imageUrl: imageUrl));
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'bookId': bookId, 'quantity': 1}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCart(); // reload จาก server
      }
    } catch (e) {
      print('addItem error: $e');
    }
  }

  // DELETE /cart/remove/:id
  Future<void> removeItem(CartItem item) async {
    try {
      final token = await _getToken();
      if (token != null && item.id != null) {
        await http.delete(
          Uri.parse('$_baseUrl/cart/remove/${item.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
      _items.remove(item);
      notifyListeners();
    } catch (e) {
      print('removeItem error: $e');
      _items.remove(item);
      notifyListeners();
    }
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}

class CartProviderWidget extends InheritedNotifier<CartProvider> {
  const CartProviderWidget({
    super.key,
    required CartProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static CartProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartProviderWidget>()!
        .notifier!;
  }
}