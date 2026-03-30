import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final double price;
  final String imageUrl;
  int quantity;
  bool isSelected;

  CartItem({
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  void addItem({
    required String title,
    required double price,
    required String imageUrl,
  }) {
    final existing = _items.where((i) => i.title == title && i.price == price);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(title: title, price: price, imageUrl: imageUrl));
    }
    notifyListeners();
  }

  void increment(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decrement(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void toggleSelect(int index, bool value) {
    _items[index].isSelected = value;
    notifyListeners();
  }

  void toggleSelectAll(bool value) {
    for (final i in _items) {
      i.isSelected = value;
    }
    notifyListeners();
  }

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((i) => i.isSelected);

  double get subtotal => _items
      .where((i) => i.isSelected)
      .fold(0, (sum, i) => sum + i.price * i.quantity);
}

// ── InheritedWidget wrapper (ไม่ต้องลง package เพิ่ม) ──
class CartProviderWidget extends InheritedNotifier<CartProvider> {
  const CartProviderWidget({
    super.key,
    required CartProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static CartProvider of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<CartProviderWidget>();
    assert(widget != null, 'No CartProviderWidget found in context');
    return widget!.notifier!;
  }
}