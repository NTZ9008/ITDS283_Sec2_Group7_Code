import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryItem {
  final int? id;
  final int? bookId;
  final String title;
  final String author;
  final String imageUrl;
  final String pdfUrl;
  bool isDownloaded;

  LibraryItem({
    this.id,
    this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    this.pdfUrl = '',
    this.isDownloaded = false,
  });
}

class LibraryProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';

  List<LibraryItem> _items = [];
  bool isLoading = false;

  List<LibraryItem> get items => _items;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('seller_token');
  }

  // GET /users/library
  Future<void> fetchLibrary() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _items = [];
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/library'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Library status: ${response.statusCode}');
      print('Library body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['library'] ?? data['items'] ?? data['data'] ?? []);

        _items = list.map((e) {
          final book = e['book'] ?? e;
          String imageUrl = book['imageUrl'] ?? book['image'] ?? '';
          if (imageUrl.startsWith('/uploads/')) {
            imageUrl = 'https://ebookapi.arlifzs.site$imageUrl';
          }
          String pdfUrl = book['pdfUrl'] ?? '';
          if (pdfUrl.startsWith('/uploads/')) {
            pdfUrl = 'https://ebookapi.arlifzs.site$pdfUrl';
          }
          return LibraryItem(
            id: e['id'],
            bookId: book['id'] ?? e['bookId'],
            title: book['title'] ?? '',
            author: book['author'] ?? '',
            imageUrl: imageUrl,
            pdfUrl: pdfUrl,
            isDownloaded: e['isDownloaded'] ?? false,
          );
        }).toList();
      }
    } catch (e) {
      print('fetchLibrary error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // เพิ่มหนังสือหลังจากซื้อ (local fallback)
  void addItems(List<dynamic> newItems) {
    for (var item in newItems) {
      bool isExist = _items.any((e) => e.title == item['title']);
      if (!isExist) {
        _items.add(LibraryItem(
          title: item['title'] ?? '',
          author: item['author'] ?? '',
          imageUrl: item['imageUrl'] ?? '',
        ));
      }
    }
    notifyListeners();
  }

  void toggleDownload(int index) {
    _items[index].isDownloaded = !_items[index].isDownloaded;
    notifyListeners();
  }
}

class LibraryProviderWidget extends InheritedNotifier<LibraryProvider> {
  const LibraryProviderWidget({
    super.key,
    required LibraryProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static LibraryProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LibraryProviderWidget>()!
        .notifier!;
  }
}