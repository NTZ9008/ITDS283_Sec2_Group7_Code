import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // หน่วงเวลาโชว์โลโก้ 3 วินาที
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final auth = AuthProviderWidget.of(context);

      if (auth.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '67-E Book',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00D13B),
            letterSpacing: 1.2,
            fontFamily: 'Jua',
          ),
        ),
      ),
    );
  }
}
