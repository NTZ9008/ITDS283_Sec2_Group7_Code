import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../routes/app_routes.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

const List<Color> _bookBgColors = [
  Color(0xFFB2EEF4), // ฟ้า
  Color(0xFFFFCDD2), // ชมพู
  Color(0xFFC8E6C9), // เขียว
  Color(0xFFFFF9C4), // เหลือง
  Color(0xFFE1BEE7), // ม่วง
  Color(0xFFFFE0B2), // ส้ม
];

const List<Color> _bookColors = [
  Color(0xFF5B9BD5), // ฟ้า
  Color(0xFFE57373), // แดง
  Color(0xFF66BB6A), // เขียว
  Color(0xFFFFCA28), // เหลือง
  Color(0xFFAB47BC), // ม่วง
  Color(0xFFFF8A65), // ส้ม
];

class ProductCard extends StatefulWidget {
  final String title;
  final String author;
  final String description;
  final double price;
  final String imageUrl;
  final int? bookId;
  final int index;

  const ProductCard({
    super.key,
    required this.title,
    this.author = '',
    required this.description,
    required this.price,
    required this.imageUrl,
    this.bookId,
    this.index = 0,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool get _isAsset => widget.imageUrl.startsWith('assets/');

  Color get _bgColor => _bookBgColors[widget.index % _bookBgColors.length];
  Color get _bookColor => _bookColors[widget.index % _bookColors.length];

  Widget _buildImage() {
    if (_isAsset) {
      return Image.asset(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _BookPlaceholder(bgColor: _bgColor, bookColor: _bookColor),
      );
    } else {
      // 🛑 เปลี่ยนมาใช้ CachedNetworkImage เพื่อให้ออฟไลน์ดูได้
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00D13B),
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) =>
            _BookPlaceholder(bgColor: _bgColor, bookColor: _bookColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = FavoriteProviderWidget.of(context).isFavorite(widget.title);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: {
            'title': widget.title,
            'author': widget.author.isNotEmpty
                ? widget.author
                : 'Unknown Author',
            'description': widget.description,
            'price': widget.price,
            'imageUrl': widget.imageUrl,
            'bookId': widget.bookId,
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Color(0xFFF5D6C6),
              thickness: 1.0,
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D13B),
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!AuthProviderWidget.of(context).isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to add favorites'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        FavoriteProviderWidget.of(context).toggleFavorite(
                          title: widget.title,
                          description: widget.description,
                          price: widget.price,
                          imageUrl: widget.imageUrl,
                          bookId: widget.bookId,
                        );
                      },
                      child: Icon(
                        isFav ? Remix.heart_3_fill : Remix.heart_3_line,
                        color: isFav
                            ? Colors.red.withValues(alpha: 0.8)
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        // 1. ดักให้ล็อกอินก่อน
                        if (!AuthProviderWidget.of(context).isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please login to add items to cart',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // 🛑 2. ดักว่าถ้ามีในคลังแล้ว ห้ามเอาลงตะกร้า
                        final isOwned = LibraryProviderWidget.of(
                          context,
                        ).items.any((item) => item.title == widget.title);

                        if (isOwned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You already own "${widget.title}"',
                              ),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // 3. ถ้าผ่านฉลุย ค่อยโยนลงตะกร้า
                        CartProviderWidget.of(context).addItem(
                          title: widget.title,
                          price: widget.price,
                          imageUrl: widget.imageUrl,
                          bookId: widget.bookId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "${widget.title}" to cart'),
                            backgroundColor: const Color(0xFF00D13B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Remix.add_circle_fill,
                        color: Color(0xFF006B3F),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookPlaceholder extends StatelessWidget {
  final Color bgColor;
  final Color bookColor;

  const _BookPlaceholder({required this.bgColor, required this.bookColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Center(
        child: CustomPaint(
          size: const Size(80, 90),
          painter: _BookPainter(bookColor: bookColor),
        ),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  final Color bookColor;
  const _BookPainter({required this.bookColor});

  @override
  void paint(Canvas canvas, Size size) {
    final spineW = size.width * 0.12;
    final spineColor = Color.fromARGB(
      (bookColor.a * 255.0).round().clamp(0, 255),
      (bookColor.r * 255.0 * 0.7).round().clamp(0, 255),
      (bookColor.g * 255.0 * 0.7).round().clamp(0, 255),
      (bookColor.b * 255.0 * 0.7).round().clamp(0, 255),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, spineW, size.height),
      Paint()..color = spineColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(spineW, 0, size.width - spineW, size.height),
      Paint()..color = bookColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 5, size.height * 0.05, 5, size.height * 0.9),
      Paint()..color = const Color(0xFFEEEEEE),
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (0.25 * i);
      canvas.drawLine(
        Offset(spineW + 8, y),
        Offset(size.width - 10, y),
        linePaint,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.6, 0)
        ..lineTo(size.width * 0.75, 0)
        ..lineTo(size.width * 0.75, size.height * 0.28)
        ..lineTo(size.width * 0.675, size.height * 0.22)
        ..lineTo(size.width * 0.6, size.height * 0.28)
        ..close(),
      Paint()..color = const Color(0xFFE53935),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
