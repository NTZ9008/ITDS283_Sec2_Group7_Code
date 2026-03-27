import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/read_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String productDetail = '/product-detail';
  static const String search = '/search';
  static const String checkout = '/checkout';
  static const String lib = '/lib';
  static const String read = '/read';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      main: (context) => const MainScreen(),
      productDetail: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProductDetailScreen(
          title: args['title'] ?? '',
          author: args['author'] ?? '',
          description: args['description'] ?? '',
          price: args['price'] ?? 0.0,
          imageUrl: args['imageUrl'] ?? '',
        );
      },
      checkout: (context) => const CheckoutScreen(),
      search: (context) => const SearchScreen(),
      lib: (context) => const LibraryScreen(),
      read: (context) => const ReadScreen(),
    };
  }
}
