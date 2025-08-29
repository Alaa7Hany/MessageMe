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

  Future<QuerySnapshot<Map<String, dynamic>>> getMessagesPage(
    String chatId, {
    int limit = 25,
    DocumentSnapshot? lastMessageDoc,
  }) async {
    // Start building the query to get messages in reverse chronological order
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId)
        .collection(FirebaseKeys.messagesCollection)
        .orderBy(FirebaseKeys.timeSent, descending: true);

    // If we have a reference to the last document, start the new query after it
    if (lastMessageDoc != null) {
      query = query.startAfterDocument(lastMessageDoc);
    }

    // Return the limited number of documents
    return await query.limit(limit).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNewMessagesStream(
    String chatId,
    Timestamp lastVisibleMessageTimestamp,
  ) {
    return _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId)
        .collection(FirebaseKeys.messagesCollection)
        .orderBy(FirebaseKeys.timeSent, descending: false)
        // Fetch any message sent after the last one we've seen
        .where(
          FirebaseKeys.timeSent,
          isGreaterThan: lastVisibleMessageTimestamp,
        )
        .snapshots();
  }

  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    await _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId)
        .collection(FirebaseKeys.messagesCollection)
        .add(messageData);
  }

  // Do multiple writes at the same time
  Future<void> sendChatMessageWithBatch(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    final chatRef = _firestore
        .collection(FirebaseKeys.chatsCollection)
        .doc(chatId);
    final newMessageRef = chatRef
        .collection(FirebaseKeys.messagesCollection)
        .doc();

    final WriteBatch batch = _firestore.batch();

    // Operation 1: Set the new message
    batch.set(newMessageRef, messageData);

    // Operation 2: Update the parent chat document
    batch.update(chatRef, {
      FirebaseKeys.lastMessageContent: messageData[FirebaseKeys.content],
      FirebaseKeys.lastMessageType: messageData[FirebaseKeys.type],
      FirebaseKeys.lastActive:
          messageData[FirebaseKeys.timeSent], // Also update timestamp
    });

    // Commit both operations at once
    await batch.commit();
  }
}
