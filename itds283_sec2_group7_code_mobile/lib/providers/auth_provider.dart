import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  void login(String username, String email) {
    _isLoggedIn = true;
    _username = username;
    _email = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _username = '';
    _email = '';
    notifyListeners();
  }
}

// ── InheritedWidget wrapper ──
class AuthProviderWidget extends InheritedNotifier<AuthProvider> {
  const AuthProviderWidget({
    super.key,
    required AuthProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static AuthProvider of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<AuthProviderWidget>();
    assert(widget != null, 'No AuthProviderWidget found in context');
    return widget!.notifier!;
  }
}