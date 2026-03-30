import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = 'Guest';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  void login(String name, String mail) {
    _isLoggedIn = true;
    _username = name;
    _email = mail;
    notifyListeners();
  }

  // ฟังก์ชันออกจากระบบ
  void logout() {
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
    return context.dependOnInheritedWidgetOfExactType<AuthProviderWidget>()!.notifier!;
  }
}