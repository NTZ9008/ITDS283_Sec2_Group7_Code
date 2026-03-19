import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      main: (context) => const MainScreen(),
    };
  }
}
