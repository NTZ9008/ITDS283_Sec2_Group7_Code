import 'package:flutter/material.dart';

class FavoriteItem {
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  FavoriteItem({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class FavoriteProvider extends ChangeNotifier {
  final List<FavoriteItem> _items = [];

  List<FavoriteItem> get items => _items;

  // ตรวจสอบว่ามีสินค้านี้ใน Favorite ไหม
  bool isFavorite(String title) {
    return _items.any((item) => item.title == title);
  }

  // กดปุ่ม Favorite (ถ้ามีแล้วจะลบ ถ้าไม่มีจะเพิ่ม)
  void toggleFavorite({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) {
    final isExist = isFavorite(title);
    if (isExist) {
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
    return context.dependOnInheritedWidgetOfExactType<FavoriteProviderWidget>()!.notifier!;
  }
}