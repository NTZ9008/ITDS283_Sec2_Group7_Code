import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../routes/app_routes.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String description;
  final double price;
  final String imageUrl;
  final int? bookId;

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.bookId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool get _isAsset => widget.imageUrl.startsWith('assets/');

  Widget _buildImage() {
    if (_isAsset) {
      return Image.asset(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _BookPlaceholder(),
      );
    } else {
      return Image.network(
        widget.imageUrl,
        key: ValueKey(widget.imageUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00D13B),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const _BookPlaceholder(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              _buildBookImage(),
              const SizedBox(height: 24),
              _buildTitleRow(),
              const SizedBox(height: 4),
              _buildAuthorPriceRow(),
              const SizedBox(height: 20),
              _buildDescribeSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Remix.arrow_left_s_line,
          size: 30,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBookImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        width: double.infinity,
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFB2EEF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    final isFav = FavoriteProviderWidget.of(context).isFavorite(widget.title);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF006B3F),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Remix.heart_3_fill : Remix.heart_3_line,
                color: isFav ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorPriceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.author,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          Text(
            '\$${widget.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescribeSection() {
    final libraryProvider = LibraryProviderWidget.of(context);
    final int ownedBookIndex = libraryProvider.items.indexWhere(
      (item) => item.title == widget.title,
    );
    final bool isOwned =
        ownedBookIndex != -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Describe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: isOwned
                ? [
                    _buildButton(
                      'Read Now',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.read,
                          arguments: {'bookIndex': ownedBookIndex},
                        );
                      },
                    ),
                  ]
                : [
                    _buildButton(
                      'Add To Cart',
                      onTap: () {
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

                        final cart = CartProviderWidget.of(context);
                        final alreadyInCart = cart.items.any(
                          (item) => item.title == widget.title,
                        );

                        if (alreadyInCart) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '"${widget.title}" is already in your cart',
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        cart.addItem(
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildButton(
                      'Buy Now',
                      onTap: () async {
                        if (!AuthProviderWidget.of(context).isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to buy items'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final cart = CartProviderWidget.of(context);
                        final alreadyInCart = cart.items.any(
                          (item) => item.title == widget.title,
                        );

                        if (!alreadyInCart) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preparing your order...'),
                              backgroundColor: Colors.blueAccent,
                              duration: Duration(seconds: 1),
                            ),
                          );

                          await cart.addItem(
                            title: widget.title,
                            price: widget.price,
                            imageUrl: widget.imageUrl,
                            bookId: widget.bookId,
                          );
                        }

                        final subtotal = cart.items.fold(
                          0.0,
                          (sum, item) => sum + item.price,
                        );
                        final checkoutItems = cart.items
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
                            'items': checkoutItems,
                            'subtotal': subtotal,
                            'discount': 0.0,
                            'total': subtotal,
                          },
                        );
                      },
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, {required VoidCallback onTap}) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D13B),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BookPlaceholder extends StatelessWidget {
  const _BookPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB2EEF4),
      child: Center(
        child: CustomPaint(size: const Size(120, 140), painter: _BookPainter()),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final spineW = size.width * 0.12;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, spineW, size.height),
      Paint()..color = const Color(0xFF3A6BC4),
    );
    canvas.drawRect(
      Rect.fromLTWH(spineW, 0, size.width - spineW, size.height),
      Paint()..color = const Color(0xFF5B9BD5),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 6, size.height * 0.05, 6, size.height * 0.9),
      Paint()..color = const Color(0xFFEEEEEE),
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (0.25 * i);
      canvas.drawLine(
        Offset(spineW + 10, y),
        Offset(size.width - 12, y),
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
