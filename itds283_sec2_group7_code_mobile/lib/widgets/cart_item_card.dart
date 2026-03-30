import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class CartItemCard extends StatefulWidget {
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onDelete;

  const CartItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.isChecked = false,
    this.onCheckboxChanged,
    this.onIncrement,
    this.onDecrement,
    this.onDelete,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.isChecked,
            onChanged: widget.onCheckboxChanged,
            activeColor: const Color(0xFF00D13B),
          ),
          const SizedBox(width: 5),

          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.cyan.shade100, // สีฟ้าอ่อน
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Remix.book_read_line,
              color: Colors.blueAccent,
              size: 35,
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D13B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              // เส้นกั้น
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              const SizedBox(width: 10),

              Column(
                children: [
                  Row(
                    children: [
                      _buildQtyButton(Remix.subtract_line, widget.onDecrement),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildQtyButton(Remix.add_line, widget.onIncrement),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // ปุ่มลบ
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(
                      Remix.delete_bin_line,
                      color: Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black54, size: 16),
      ),
    );
  }
}
