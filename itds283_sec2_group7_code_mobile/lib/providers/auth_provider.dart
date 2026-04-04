import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = 'Guest';
  String _email = '';
  String? _token;
  String _role = 'buyer';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;
  String? get token => _token;
  String get role => _role;

  // 🛑 รับค่าที่โหลดเสร็จแล้วจาก main.dart เข้ามาใช้งานเลย
  AuthProvider({
    bool isLoggedIn = false,
    String username = 'Guest',
    String email = '',
    String? token,
    String role = 'buyer',
  }) {
    _isLoggedIn = isLoggedIn;
    _username = username;
    _email = email;
    _token = token;
    _role = role;
    
    _initAuthState();
  }

  void _initAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && _token == null) {
        _isLoggedIn = false;
        _username = 'Guest';
        _email = '';
        _token = null;
        _role = 'buyer';
        notifyListeners();
      }
    });
  }

  Future<void> login(
    String name,
    String mail, {
    String? token,
    String role = 'buyer',
  }) async {
    _isLoggedIn = true;
    _username = name;
    _email = mail;
    _token = token;
    _role = role;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token ?? '');
    await prefs.setString('username', name);
    await prefs.setString('email', mail);
    await prefs.setString('role', role);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    _isLoggedIn = false;
    _username = 'Guest';
    _email = '';
    _token = null;
    _role = 'buyer';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('role');
  }
}

class AuthProviderWidget extends InheritedNotifier<AuthProvider> {
  const AuthProviderWidget({
    super.key,
    required AuthProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AuthProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AuthProviderWidget>()!
        .notifier!;
  }
}