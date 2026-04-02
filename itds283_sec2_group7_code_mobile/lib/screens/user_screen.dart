import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'favorites_screen.dart';
import 'library_screen.dart';
import 'login_screen.dart';
import 'my_products_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthProviderWidget.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _sectionLabel('User Info'),
                    const SizedBox(height: 16),
                    _sectionLabel('My Account'),
                    const SizedBox(height: 10),
                    auth.isLoggedIn
                        ? _buildAccountCard(auth)
                        : _buildLoginButton(context),
                    const SizedBox(height: 24),
                    _sectionLabel('My Assets'),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      label: 'My Favorites',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritesScreen()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      label: 'My Librarys',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LibraryScreen()),
                      ),
                    ),
                    
                    // เพิ่มเงื่อนไขตรวจสอบว่า Login แล้ว และ Role เป็น Seller เท่านั้น
                    if (auth.isLoggedIn && auth.role == 'seller') ...[
                      const SizedBox(height: 24),
                      _sectionLabel('Seller Zone'),
                      const SizedBox(height: 10),
                      _buildMenuItem(
                        label: 'My Products',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyProductsScreen()),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (auth.isLoggedIn) _buildLogoutButton(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final isTitle = text == 'User Info';
    return Text(
      text,
      style: TextStyle(
        fontSize: isTitle ? 20 : 15,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF00D13B),
      ),
    );
  }

  Widget _buildAccountCard(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.black38, size: 30),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auth.username,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(auth.email,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006B3F),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Login',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuItem(
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87)),
            const Icon(Icons.chevron_right,
                size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Logout'),
                content:
                    const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black54)),
                  ),
                  TextButton(
                    onPressed: () {
                      auth.logout();
                      Navigator.pop(context);
                    },
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Logout',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}