import 'package:flutter/material.dart';

class LibraryItem {
  final String title;
  final String author;
  final String imageUrl;
  bool isDownloaded;

  LibraryItem({
    required this.title,
    required this.author,
    required this.imageUrl,
    this.isDownloaded = false,
  });
}

class LibraryProvider extends ChangeNotifier {
  final List<LibraryItem> _items = [];

  List<LibraryItem> get items => _items;

  // ฟังก์ชันเพิ่มหนังสือเข้าคลังหลังจากจ่ายเงิน
  void addItems(List<dynamic> newItems) {
    for (var item in newItems) {
      // เช็คว่ามีหนังสือเล่มนี้ในคลังหรือยัง (ป้องกันซื้อซ้ำแล้วซ้อนกัน)
      bool isExist = _items.any((existing) => existing.title == item['title']);
      if (!isExist) {
        _items.add(
          LibraryItem(
            title: item['title'] ?? 'Unknown Book',
            author: item['author'] ?? 'Unknown Author',
            imageUrl:
                item['imageUrl'] ??
                'https://cdn-icons-png.flaticon.com/512/3145/3145765.png',
          ),
        );
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
