import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';

import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService(this._firestore);

  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    await _firestore
        .collection(FirebaseKeys.usersCollection)
        .doc(uid)
        .set(userData);
  }

  Future<DocumentSnapshot?> getUser(String userId) async {
    final doc = await _firestore
        .collection(FirebaseKeys.usersCollection)
        .doc(userId)
        .get();
    if (doc.exists) {
      return doc;
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(FirebaseKeys.usersCollection)
        .doc(user.uid)
        .update(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(FirebaseKeys.usersCollection)
        .doc(userId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChats(String uid) {
    return _firestore
        .collection(FirebaseKeys.chatsCollection)
        .where(FirebaseKeys.members, arrayContains: uid)
        .orderBy(
          FirebaseKeys.lastActive,
          descending: true,
        ) // Sort by most recent
        .snapshots();
  }
}
