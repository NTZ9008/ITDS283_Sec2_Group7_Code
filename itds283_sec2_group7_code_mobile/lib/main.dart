import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/library_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProviderWidget(
      notifier: AuthProvider(),
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
