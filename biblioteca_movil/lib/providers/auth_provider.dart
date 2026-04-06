import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _user;
  User? get user => _user;
  
  bool get isAuthenticated => _user != null;

  AuthProvider(this._authRepository) {
    _user = _authRepository.currentUser;
    _authRepository.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    await _authRepository.signIn(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _authRepository.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
