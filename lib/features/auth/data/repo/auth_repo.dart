import 'package:firebase_auth/firebase_auth.dart';
import 'package:message_me/core/models/user_model.dart';

import '../../../../core/firebase/auth_service.dart';
import '../../../../core/firebase/database_service.dart';

class AuthRepo {
  final AuthService _authService;
  final DatabaseService _databaseService;

  AuthRepo(this._authService, this._databaseService);

  void setupAuthStateListener(void Function(User?) onAuthStateChanged) {
    _authService.setupAuthStateListener(onAuthStateChanged);
  }

  Future<String?> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    return 'Login Successful';
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _databaseService.getUser(userId);
      if (doc != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
