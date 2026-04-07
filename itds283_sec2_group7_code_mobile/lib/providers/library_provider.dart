import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'isDownloaded': isDownloaded,
      'book': {
        'title': title,
        'author': author,
        'imageUrl': imageUrl,
        'pdfUrl': pdfUrl,
      },
    };
  }
}

class LibraryProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://ebookapi.arlifzs.site/api';
  static const String _offlineKey = 'offline_library_cache';

  List<LibraryItem> _items = [];
  bool isLoading = false;

  List<LibraryItem> get items => _items;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('seller_token');
  }

  Future<void> _syncWithFileSystem() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      for (var item in _items) {
        if (item.pdfUrl.isNotEmpty) {
          final fileName = item.pdfUrl.split('/').last;
          final file = File('${dir.path}/$fileName');
          item.isDownloaded = await file.exists();
        }
      }
      notifyListeners();
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  Future<void> _saveOfflineCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonData = jsonEncode(
        _items.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_offlineKey, jsonData);
    } catch (e) {
      print('Error saving offline cache: $e');
    }
  }

  List<LibraryItem> _parseItems(List<dynamic> list) {
    return list.map((e) {
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

  Future<void> fetchLibrary() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_offlineKey);
      if (cachedData != null) {
        _items = _parseItems(jsonDecode(cachedData));
        await _syncWithFileSystem();
      }
    } catch (e) {
      print("Cache load error: $e");
    }

    try {
      final token = await _getToken();
      if (token == null) {
        _items = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/library'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data is List
            ? data
            : (data['library'] ?? data['items'] ?? data['data'] ?? []);

        _items = _parseItems(list);
        await _syncWithFileSystem();
        await _saveOfflineCache();
      }
    } catch (e) {
      print('fetchLibrary error: $e');
      await _syncWithFileSystem();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllOfflineData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          await file.delete();
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineKey);

      _items = [];
      notifyListeners();
    } catch (e) {
      print("Clear Offline Data Error: $e");
    }
  }

  void addItems(List<dynamic> newItems) {
    for (var item in newItems) {
      bool isExist = _items.any((e) => e.title == item['title']);
      if (!isExist) {
        _items.add(
          LibraryItem(
            title: item['title'] ?? '',
            author: item['author'] ?? '',
            imageUrl: item['imageUrl'] ?? '',
          ),
        );
      }
    }
    _syncWithFileSystem();
    _saveOfflineCache();
    notifyListeners();
  }

  void toggleDownload(int index) {
    _items[index].isDownloaded = !_items[index].isDownloaded;
    _saveOfflineCache();
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
