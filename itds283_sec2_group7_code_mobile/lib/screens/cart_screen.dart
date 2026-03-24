import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _promoApplied = false;
  final double _deliveryFee = 4.90;
  final double _discountPercent = 0.20;

  double _discount(double subtotal) =>
      _promoApplied ? subtotal * _discountPercent : 0;

  double _total(double subtotal) =>
      subtotal + _deliveryFee - _discount(subtotal);

  void _applyPromo() {
    if (_promoController.text.trim().isNotEmpty) {
      setState(() => _promoApplied = true);
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProviderWidget.of(context);
    final items = cart.items;
    final subtotal = cart.subtotal;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    if (items.isEmpty)
                      _buildEmpty()
                    else ...[
                      _buildSelectAll(cart),
                      _buildCartList(cart),
                      const SizedBox(height: 12),
                      _buildPromoCode(),
                      const SizedBox(height: 12),
                      _buildPriceSummary(subtotal),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (items.isNotEmpty) _buildCheckoutBar(subtotal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Cart',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D13B))),
          Text('One step away from new knowledge.',
              style: TextStyle(fontSize: 13, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text('Your cart is empty',
                style: TextStyle(fontSize: 16, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAll(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CheckboxListTile(
          value: cart.isAllSelected,
          onChanged: (v) => cart.toggleSelectAll(v ?? false),
          title: const Text('Select all',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          activeColor: const Color(0xFF00D13B),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: true,
        ),
      ),
    );
  }

  Widget _buildCartList(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          cart.items.length,
          (i) => _buildCartItem(cart, i),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartProvider cart, int index) {
    final item = cart.items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: (v) => cart.toggleSelect(index, v ?? true),
            activeColor: const Color(0xFF00D13B),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFB2EEF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl.startsWith('assets/')
                  ? Image.asset(item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, _) => const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF5B9BD5),
                          size: 30))
                  : Image.network(item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, _) => const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF5B9BD5),
                          size: 30)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text('\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(Icons.remove, () => cart.decrement(index)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${item.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              _qtyButton(Icons.add, () => cart.increment(index)),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildPromoCode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: _promoApplied
                  ? const Color(0xFF00D13B)
                  : Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                enabled: !_promoApplied,
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  suffixIcon: _promoApplied
                      ? const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Promo code applied',
                                  style: TextStyle(
                                      color: Color(0xFF00D13B),
                                      fontSize: 12)),
                              SizedBox(width: 4),
                              Icon(Icons.check_circle,
                                  color: Color(0xFF00D13B), size: 16),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (!_promoApplied)
              GestureDetector(
                onTap: _applyPromo,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D13B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(double subtotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _priceRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _priceRow(
              'Delivery Fee:', '\$${_deliveryFee.toStringAsFixed(2)}'),
          if (_promoApplied) ...[
            const SizedBox(height: 4),
            _priceRow('Discount:',
                '${(_discountPercent * 100).toInt()}%',
                valueColor: const Color(0xFF00D13B)),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCheckoutBar(double subtotal) {
    final total = _total(subtotal);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 12, color: Colors.black45)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.checkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D13B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Checkout',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}