import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteItem {
  final int? bookId;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  FavoriteItem({
    this.bookId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class FavoriteProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  List<FavoriteItem> _items = [];
  bool isLoading = false;

  List<FavoriteItem> get items => _items;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('seller_token');
  }

  bool isFavorite(String title) {
    return _items.any((item) => item.title == title);
  }

  // GET /users/favorites
  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _items = [];
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list =
            data is List ? data : (data['favorites'] ?? data['data'] ?? []);

        _items = list.map((e) {
          String imageUrl = e['imageUrl'] ?? e['image'] ?? '';
          if (imageUrl.startsWith('/uploads/')) {
            imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
          }
          return FavoriteItem(
            bookId: e['id'],
            title: e['title'] ?? '',
            description: e['description'] ?? '',
            price: (e['price'] is String
                    ? double.tryParse(e['price'])
                    : e['price']?.toDouble()) ??
                0.0,
            imageUrl: imageUrl,
          );
        }).toList();
      }
    } catch (e) {
      print('fetchFavorites error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // POST /users/favorites/toggle
  Future<void> toggleFavorite({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
    int? bookId,
  }) async {
    try {
      final token = await _getToken();

      // ถ้าไม่มี token หรือ bookId → ทำแบบ local
      if (token == null || bookId == null) {
        _toggleLocal(title, description, price, imageUrl);
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/users/favorites/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'bookId': bookId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final isFav = data['isFavorite'] ?? false;

        if (isFav) {
          if (!isFavorite(title)) {
            String resolvedUrl = imageUrl;
            if (resolvedUrl.startsWith('/uploads/')) {
              resolvedUrl = 'https://ebookapi.arlifzs.site$resolvedUrl';
            }
            _items.add(FavoriteItem(
              bookId: bookId,
              title: title,
              description: description,
              price: price,
              imageUrl: resolvedUrl,
            ));
          }
        } else {
          _items.removeWhere((item) => item.title == title);
        }
        notifyListeners();
      }
    } catch (e) {
      print('toggleFavorite error: $e');
      _toggleLocal(title, description, price, imageUrl);
    }
  }

  void _toggleLocal(String title, String description, double price, String imageUrl) {
    if (isFavorite(title)) {
      _items.removeWhere((item) => item.title == title);
    } else {
      _items.add(FavoriteItem(
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
    }
    notifyListeners();
  }
}

class FavoriteProviderWidget extends InheritedNotifier<FavoriteProvider> {
  const FavoriteProviderWidget({
    super.key,
    required FavoriteProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static FavoriteProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FavoriteProviderWidget>()!
        .notifier!;
  }
}