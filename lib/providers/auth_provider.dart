import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WizmiAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  String _name = '';
  String _phone = '';
  bool _loading = false;

  String get name => _name;
  String get phone => _phone;
  bool get loading => _loading;

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _name = doc['name'] ?? '';
      _phone = doc['phone'] ?? '';
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (!cred.user!.emailVerified) {
        _loading = false;
        notifyListeners();
        return 'Please verify your email first.';
      }
      await loadUserData();
      _loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      return _mapError(e.code);
    }
  }

  Future<String?> signup(String name, String email, String phone, String password) async {
    try {
      _loading = true;
      notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.sendEmailVerification();
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'phone': phone,
        'createdAt': Timestamp.now(),
      });
      _loading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      return _mapError(e.code);
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _name = '';
    _phone = '';
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
