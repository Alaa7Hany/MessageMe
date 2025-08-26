import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  void setupAuthStateListener(void Function(User?) onAuthStateChanged) {
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
