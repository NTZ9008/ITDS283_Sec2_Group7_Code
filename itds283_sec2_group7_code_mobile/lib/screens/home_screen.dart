import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '67-E Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            SizedBox(height: 16),
            Text(
              'ยินดีต้อนรับสู่หน้า Home!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ทดสอบระบบ Navigation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Remix.home_2_line), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Remix.book_shelf_line),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Remix.shopping_cart_2_line),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Remix.user_line), label: 'User'),
        ],
      ),
    );
  }
}
