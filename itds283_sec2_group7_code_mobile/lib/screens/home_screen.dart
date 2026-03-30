import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🛑 1. ตัวแปรเก็บ index ที่ถูกเลือก และรายชื่อ Category พร้อมไอคอนตามวิชา
  int _selectedCategoryIndex = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'icon': Remix.function_line, 'name': 'Math'}, // ไอคอนฟังก์ชันเลข
    {'icon': Remix.microscope_line, 'name': 'Science'}, // ไอคอนกล้องจุลทรรศน์
    {'icon': Remix.book_read_line, 'name': 'English'}, // ไอคอนอ่านหนังสือ
    {'icon': Remix.leaf_line, 'name': 'Bio'}, // ไอคอนใบไม้สำหรับชีวะ
    {'icon': Remix.test_tube_line, 'name': 'Chemi'}, // ไอคอนหลอดทดลองสำหรับเคมี
    {'icon': Remix.atom_line, 'name': 'Physic'}, // ไอคอนอะตอมสำหรับฟิสิกส์
  ];

  // 🛑 2. Mock Data: ข้อมูลหนังสือที่ติด Tag Category ตามวิชาใหม่
  final List<Map<String, dynamic>> mockProducts = const [
    {
      'title': 'Calculus Mastery',
      'description': 'เจาะลึกแคลคูลัส 1-3 ครบจบในเล่มเดียว',
      'price': 250.00,
      'category': 'Math', // หมวดเลข
      'imageUrl': 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'The Science of Space',
      'description': 'สำรวจจักรวาลอันกว้างใหญ่',
      'price': 199.00,
      'category': 'Science', // หมวดวิทย์
      'imageUrl': 'https://images.unsplash.com/photo-1555099962-4199c345e5dd?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'English Grammar Pro',
      'description': 'สรุปแกรมม่าครบทุกเรื่องเตรียมสอบ T-GAT',
      'price': 310.00,
      'category': 'English', // หมวดอังกฤษ
      'imageUrl': 'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Plant Cell Biology',
      'description': 'โครงสร้างและหน้าที่ของเซลล์พืช',
      'price': 299.00,
      'category': 'Bio', // หมวดชีวะ
      'imageUrl': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'Statistics for CompSci',
      'description': 'สถิติสำหรับวิทยาการคอมพิวเตอร์',
      'price': 210.00,
      'category': 'Math', // หมวดเลข
      'imageUrl': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=400&auto=format&fit=crop',
    },
  ];

  // 🛑 3. ฟังก์ชันกรองสินค้า: ดึงมาเฉพาะเล่มที่ category ตรงกับที่ผู้ใช้กดเลือก
  List<Map<String, dynamic>> get _filteredProducts {
    // ดึงชื่อหมวดหมู่ที่เลือกอยู่ปัจจุบัน เช่น 'Math'
    String selectedCatName = _categories[_selectedCategoryIndex]['name'];
    return mockProducts.where((p) => p['category'] == selectedCatName).toList();
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
              _buildHeader(context),
              _buildBanner(),
              _buildSectionTitle('Categories'),
              _buildCategories(), // แถบหมวดหมู่ที่มีไอคอนตามวิชา
              _buildSectionTitle('Best Seller'),
              _buildBestSeller(),
              _buildSectionTitle('New Collection'),
              _buildNewCollection(), // สินค้าที่ถูกกรองแล้ว
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

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Special Offer Clicked!'), duration: Duration(seconds: 1)),
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
              )
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=600&auto=format&fit=crop',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.3), 
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text('PROMO', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Special Offer\nGet 20% Off', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
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

  // 🛑 4. อัปเดต Categories: หน้าตาเหมือนเดิม (ไอคอนในช่องสี่เหลี่ยม) แต่ข้อมูลเป็นวิชาตาม reference
  Widget _buildCategories() {
    return SizedBox(
      height: 90, // เผื่อความสูงให้ชื่อด้านล่าง
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
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
                          ? const Color(0xFF006B3F) // สีเขียวเข้มเมื่อเลือก
                          : const Color(0xFF00D13B).withValues(alpha: 0.1), // สีเขียวจางๆ เมื่อไม่ได้เลือก
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF00D13B).withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF006B3F) : Colors.black54,
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
    // 🛑 5. เรียกใช้สินค้าที่ถูกกรอง (_filteredProducts) แทนของเดิม
    final displayProducts = _filteredProducts;

    if (displayProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text('No books in this category yet.', style: TextStyle(color: Colors.black45)),
        ),
      );
    }

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
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];

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