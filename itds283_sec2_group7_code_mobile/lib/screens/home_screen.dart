import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final List<Map<String, dynamic>> mockProducts = const [
    {
      'id': 1,
      'title': 'Mobile',
      'description': 'เจาะลึกการออกแบบ UI และ Animation ใน Flutter แบบมืออาชีพ',
      'price': 199.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 2,
      'title': 'Mobile',
      'description': 'เจาะลึกการออกแบบ UI และ Animation ใน Flutter แบบมืออาชีพ',
      'price': 199.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 3,
      'title': 'Mobile',
      'description': 'เจาะลึกการออกแบบ UI และ Animation ใน Flutter แบบมืออาชีพ',
      'price': 199.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 4,
      'title': 'Mobile',
      'description': 'เจาะลึกการออกแบบ UI และ Animation ใน Flutter แบบมืออาชีพ',
      'price': 199.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBanner(),
              _buildSectionTitle('Categories'),
              _buildCategories(),
              _buildSectionTitle('Best Seller'),
              _buildBestSeller(),
              _buildSectionTitle('New Collection'),
              _buildNewCollection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D13B),
                ),
              ),
              Text(
                'Ready to learn something new today?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00D13B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Remix.search_line, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: NetworkImage(
              'https://via.placeholder.com/400x150/FFB74D/FFFFFF?text=Special+Offer+Banner',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00D13B),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final icons = [
      Remix.reactjs_line,
      Remix.arrow_up_down_line,
      Remix.vip_crown_line,
      Remix.focus_2_line,
      Remix.heart_line,
    ];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 1;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 70,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF006B3F)
                  : const Color(0xFF00D13B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icons[index],
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF00D13B).withOpacity(0.5),
              size: 30,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestSeller() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF00D13B).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book AAAA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'AAAAAAAA\nAAAAAA',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Shop Now', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewCollection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.50,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: mockProducts.length,
        itemBuilder: (context, index) {
          final product = mockProducts[index];

          return ProductCard(
            title: product['title'] ?? 'ไม่ระบุชื่อหนังสือ',
            description: product['description'] ?? '',
            price: product['price'] ?? 0.00,
            imageUrl:
                product['imageUrl'] ??
                'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=400&auto=format&fit=crop',
          );
        },
      ),
    );
  }
}
