import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message_me/core/firebase/firebase_keys.dart';

import '../helpers/my_logger.dart';

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

  Future<void> updateDataInUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(FirebaseKeys.usersCollection)
        .doc(userId)
        .update(data);
  }

  Future<void> updateDataInChat(
    String chatId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId)
        .update(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(String chatId) {
    return _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId)
        .collection(FirebaseKeys.messagesCollection)
        .orderBy(FirebaseKeys.timeSent, descending: false)
        .snapshots();
  }
}
