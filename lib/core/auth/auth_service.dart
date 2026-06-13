import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Wraps Firebase Auth — the apps' only Firebase touch-point. Signs the user in and
/// exposes the ID token; all data access goes through the backend API with that token.
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  /// Emits on sign-in / sign-out (and the current state on subscribe).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  /// Current Firebase ID token (refreshed by the SDK as needed), or null if signed out.
  Future<String?> idToken() {
    final user = _auth.currentUser;
    if (user == null) return Future.value(null);
    return user.getIdToken();
  }
}
