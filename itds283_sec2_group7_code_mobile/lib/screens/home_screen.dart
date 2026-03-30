import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/product_card.dart';

// 🛑 1. เปลี่ยนเป็น StatefulWidget เพื่อให้ Categories กดเปลี่ยนสีได้
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🛑 เพิ่มตัวแปรเก็บว่าเลือกหมวดหมู่ไหนอยู่ (ค่าเริ่มต้นคือ 0)
  int _selectedCategoryIndex = 0;

  // ข้อมูลหมวดหมู่ (มีทั้งไอคอนและชื่อ)
  final List<Map<String, dynamic>> _categories = [
    {'icon': Remix.reactjs_line, 'name': 'Coding'},
    {'icon': Remix.palette_line, 'name': 'Design'},
    {'icon': Remix.briefcase_line, 'name': 'Business'},
    {'icon': Remix.line_chart_line, 'name': 'Finance'},
    {'icon': Remix.heart_pulse_line, 'name': 'Health'},
  ];

  // (Mock Data เดิม เปลี่ยนชื่อเรื่องให้ไม่ซ้ำกันตามที่คุยกันไว้ครับ)
  final List<Map<String, dynamic>> mockProducts = const [
    {
      'title': 'Flutter Mastery',
      'description': 'เจาะลึกการออกแบบ UI และ Animation ใน Flutter แบบมืออาชีพ',
      'price': 199.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'React Native 101',
      'description': 'พื้นฐานการสร้างแอป Cross-platform ด้วย React Native',
      'price': 149.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1555099962-4199c345e5dd?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'UI/UX Design',
      'description': 'ออกแบบหน้าจอให้โดนใจผู้ใช้งานด้วย Figma',
      'price': 250.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Clean Architecture',
      'description': 'เขียนโค้ดให้ดูแลรักษาง่าย โครงสร้างชัดเจน',
      'price': 299.00,
      'imageUrl':
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=400&auto=format&fit=crop',
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
              _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/search'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00D13B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Remix.search_line, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // 🛑 2. อัปเดต Banner ให้กดได้ และดูสมจริงขึ้น
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          // อนาคตสามารถใส่คำสั่งเด้งไปหน้ารวมโปรโมชันได้
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Special Offer Clicked!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ภาพจางๆ ด้านหลัง (ถ้ารูปพังจะโชว์สี Gradient แทน)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=600&auto=format&fit=crop',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(
                    alpha: 0.3,
                  ), // ทำให้รูปมืดลงนิดนึงให้ตัวหนังสือเด่น
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
              // ข้อความโปรโมชัน
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'PROMO',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Special Offer\nGet 20% Off',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  // 🛑 3. อัปเดต Categories ให้กดเลือกได้และมีข้อความ
  Widget _buildCategories() {
    return SizedBox(
      height: 90, // เพิ่มความสูงเผื่อที่ให้ข้อความ
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index; // เปลี่ยนหมวดหมู่เมื่อกด
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF006B3F)
                          : const Color(0xFF00D13B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _categories[index]['icon'],
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF00D13B).withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _categories[index]['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF006B3F)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
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
          color: const Color(0xFF00D13B).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best Seller',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Top choices from\nour students',
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
          childAspectRatio:
              0.50, // หากเปลี่ยนชื่อหนังสือแล้วยาวไป ปรับค่านี้ให้มากขึ้นได้ครับ (เช่น 0.55)
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: mockProducts.length,
        itemBuilder: (context, index) {
          final product = mockProducts[index];

          return ProductCard(
            title: product['title'],
            description: product['description'],
            price: product['price'],
            imageUrl: product['imageUrl'],
          );
        },
      ),
    );
  }
}
