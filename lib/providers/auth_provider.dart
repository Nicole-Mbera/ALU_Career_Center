import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.role == 'student';
  bool get isFounder => _user?.role == 'founder';

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _user = await _db.getUser(firebaseUser.uid);
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String campus,
  }) async {
    _error = null;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
        campus: campus,
        skills: [],
        createdAt: DateTime.now(),
      );
      await _db.createUser(user);
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = await _db.getUser(cred.user!.uid);
      _status = AuthStatus.authenticated;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  void refreshUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _user = await _db.getUser(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(String oppId) async {
    if (_user == null) return;
    final isBookmarked = _user!.bookmarkedOppIds.contains(oppId);
    await _db.toggleBookmark(_user!.uid, oppId, isBookmarked);
    refreshUser();
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
