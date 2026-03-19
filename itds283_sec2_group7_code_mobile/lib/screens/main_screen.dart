import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cart Page'));
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Product Page'));
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('User Page'));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ProductScreen(),
    const CartScreen(),
    const UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Divider(height: 1, thickness: 1.0, color: Colors.black),
            ),
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              iconSize: 30.0,
              selectedItemColor: const Color(0xFF006B3F),
              unselectedItemColor: Colors.black,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),

              currentIndex: _currentIndex,

              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Remix.home_4_line),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Remix.book_shelf_line),
                  label: 'Product',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Remix.shopping_cart_2_line),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Remix.user_3_line),
                  label: 'User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
