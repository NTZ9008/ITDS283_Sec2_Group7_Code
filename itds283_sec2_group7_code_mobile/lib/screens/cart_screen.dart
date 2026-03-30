import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../routes/app_routes.dart';
import '../providers/cart_provider.dart'; // 🛑 เพิ่ม Import นี้

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // คำนวณราคาย่อยจาก Provider
  double _calculateSubtotal(CartProvider cart) {
    return cart.items
        .where((item) => item.selected)
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _calculateDiscount(double subtotal) {
    return (subtotal > 0 && _isPromoApplied) ? subtotal * 0.20 : 0;
  }

  bool _isAllSelected(CartProvider cart) {
    return cart.items.isNotEmpty && cart.items.every((item) => item.selected);
  }

  @override
  Widget build(BuildContext context) {
    // 🛑 ดึงข้อมูล Cart จาก Provider
    final cartProvider = CartProviderWidget.of(context);
    final items = cartProvider.items;

    final subtotal = _calculateSubtotal(cartProvider);
    final discount = _calculateDiscount(subtotal);
    final total = subtotal > 0 ? (subtotal - discount) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D13B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'One step away from new knowledge.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    if (items.isNotEmpty)
                      _buildCartItemsContainer(cartProvider),
                    if (items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "Your cart is empty.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

                    _buildSummaryContainer(subtotal, discount),
                  ],
                ),
              ),
            ),
            _buildBottomCheckoutRow(subtotal, discount, total, items),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsContainer(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCustomCheckbox(
                value: _isAllSelected(cart),
                onChanged: (value) {
                  setState(() {
                    for (var item in cart.items) {
                      item.selected = value ?? false;
                    }
                  });
                },
              ),
              const SizedBox(width: 10),
              const Text(
                'Select all',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...List.generate(cart.items.length, (index) {
            final item = cart.items[index];
            return Column(
              children: [
                if (index > 0)
                  const Divider(
                    color: Colors.black12,
                    height: 20,
                    thickness: 1,
                  ),
                Row(
                  children: [
                    _buildCustomCheckbox(
                      value: item.selected,
                      onChanged: (value) {
                        setState(() {
                          item.selected = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 10),

                    // โชว์รูปภาพจริงแทน Icon ชั่วคราว
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Remix.book_read_line,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  cart.removeItem(
                                    item,
                                  ); // 🛑 ลบไอเทมผ่าน Provider
                                }
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Icon(
                                Remix.subtract_line,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                item.quantity++;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Icon(
                                Remix.add_line,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryContainer(double subtotal, double discount) {
    // โค้ดส่วนนี้เหมือนเดิมของคุณทั้งหมดครับ แค่รับตัวแปรมาจากด้านบน
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black45, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    onChanged: (value) {
                      if (_isPromoApplied)
                        setState(() {
                          _isPromoApplied = false;
                        });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_isPromoApplied)
                  Row(
                    children: [
                      const Text(
                        'Promo code applied',
                        style: TextStyle(
                          color: Color(0xFF00D13B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Remix.checkbox_circle_fill,
                        color: Color(0xFF00D13B),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => setState(() {
                          _promoController.clear();
                          _isPromoApplied = false;
                        }),
                        child: const Icon(
                          Remix.close_circle_fill,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: () {
                      if (_promoController.text.trim() == 'ICT555') {
                        setState(() {
                          _isPromoApplied = true;
                          FocusScope.of(context).unfocus();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promo code applied successfully!'),
                            backgroundColor: Color(0xFF00D13B),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid promo code.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Color(0xFF00D13B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildSummaryRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Discount:',
            _isPromoApplied ? '-\$${discount.toStringAsFixed(2)}' : '\$0.00',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutRow(
    double subtotal,
    double discount,
    double total,
    List<CartItem> items,
  ) {
    String totalStr = total.toStringAsFixed(2);
    List<String> totalParts = totalStr.split('.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              RichText(
                text: TextSpan(
                  text: '\$${totalParts[0]}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '.${totalParts[1]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 160,
            height: 50,
            child: ElevatedButton(
              onPressed: subtotal > 0
                  ? () {
                      final selectedItems = items
                          .where((item) => item.selected)
                          .map(
                            (e) => {
                              'title': e.title,
                              'price': e.price,
                              'quantity': e.quantity,
                            },
                          )
                          .toList();

                      Navigator.pushNamed(
                        context,
                        AppRoutes.checkout,
                        arguments: {
                          'items': selectedItems,
                          'subtotal': subtotal,
                          'discount': discount,
                          'total': total,
                        },
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D13B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00A859),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Colors.black54, width: 1.5),
      ),
    );
  }
}
