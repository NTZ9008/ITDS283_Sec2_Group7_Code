import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final double price;
  final String imageUrl;
  int quantity;
  bool selected;

  CartItem({
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.selected = true,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem({required String title, required double price, required String imageUrl}) {
    var existingItem = _items.where((item) => item.title == title).firstOrNull;
    
    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(title: title, price: price, imageUrl: imageUrl)); 
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
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
    return context.dependOnInheritedWidgetOfExactType<CartProviderWidget>()!.notifier!;
  }
}