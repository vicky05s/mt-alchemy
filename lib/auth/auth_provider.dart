import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'app_user.dart';

/// Holds the logged-in user + role for the whole app.
/// Use: `context.watch<AuthProvider>()` to rebuild when login state changes.
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _user;
  bool _initialising = true; // true until Firebase tells us who is logged in
  bool _busy = false; // true while register/login is running
  String? _error;
  StreamSubscription<User?>? _sub;

  AuthProvider() {
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialising => _initialising;
  bool get busy => _busy;
  String? get error => _error;
  String get role => _user?.role ?? UserRole.guest;

  bool hasRole(List<String> allowed) => allowed.contains(role);

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      await _loadProfile(firebaseUser.uid);
    }
    _initialising = false;
    notifyListeners();
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      _user = doc.exists ? AppUser.fromMap(uid, doc.data()!) : null;
    } catch (e) {
      debugPrint('Load profile failed: $e');
      _user = null;
    }
  }

  /// Public registration: ONLY individual or employer.
  /// Trainer/admin are set by hand in the Firebase console.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> extra = const {},
  }) async {
    if (role != UserRole.individual && role != UserRole.employer) {
      _error = 'You can only register as an Individual or an Employer.';
      notifyListeners();
      return false;
    }
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        ...extra,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _loadProfile(cred.user!.uid);
      _busy = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e.code);
    } catch (e) {
      debugPrint('Register failed: $e');
      _error = 'Something went wrong. Please try again.';
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadProfile(cred.user!.uid);
      _busy = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendly(e.code);
    } catch (e) {
      debugPrint('Login failed: $e');
      _error = 'Something went wrong. Please try again.';
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  /// Sends a password-reset email. Returns true even if the email is not
  /// registered, so we do not reveal which emails have accounts.
  Future<bool> resetPassword(String email) async {
    _error = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return true;
      _error = _friendly(e.code);
    } catch (e) {
      _error = 'Could not send the reset email. Please try again.';
    }
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendly(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
