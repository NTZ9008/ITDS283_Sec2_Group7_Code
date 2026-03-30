import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = 'Guest';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _isLoggedIn = true;
        _username = user.displayName ?? 'Google User';
        _email = user.email ?? '';
      } else {
        _isLoggedIn = false;
        _username = 'Guest';
        _email = '';
      }
      notifyListeners();
    });
  }

  void login(String name, String mail) {
    _isLoggedIn = true;
    _username = name;
    _email = mail;
    notifyListeners();
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    _isLoggedIn = false;
    _username = 'Guest';
    _email = '';
    notifyListeners();
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
