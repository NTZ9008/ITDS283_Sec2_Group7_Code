import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            widget.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const Spacer(),
          const Divider(
            color: Color(0xFFF5D6C6),
            thickness: 1.0,
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D13B),
                      fontSize: 16)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Icon(
                      isFavorite ? Remix.heart_3_fill : Remix.heart_3_line,
                      color: isFavorite ? const Color(0xFF0000).withOpacity(0.8) : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Remix.add_circle_fill,
                      color: Color(0xFF006B3F), size: 24),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}