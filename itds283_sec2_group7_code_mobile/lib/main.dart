import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/library_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token');
  final savedUsername = prefs.getString('username') ?? 'Guest';
  final savedEmail = prefs.getString('email') ?? '';
  final savedRole = prefs.getString('role') ?? 'buyer';

  runApp(
    MyApp(
      token: savedToken,
      username: savedUsername,
      email: savedEmail,
      role: savedRole,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  final String username;
  final String email;
  final String role;

  const MyApp({
    super.key,
    this.token,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AuthProviderWidget(
      notifier: AuthProvider(
        isLoggedIn: token != null && token!.isNotEmpty,
        username: username,
        email: email,
        token: token,
        role: role,
      ),
      child: CartProviderWidget(
        notifier: CartProvider(),
        child: FavoriteProviderWidget(
          notifier: FavoriteProvider(),
          child: LibraryProviderWidget(
            notifier: LibraryProvider(),
            child: MaterialApp(
              title: '67-E Book',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.green,
                fontFamily: 'Kanit',
              ),
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.getRoutes(),
            ),
          ),
        ),
      ),
    );
  }
}
