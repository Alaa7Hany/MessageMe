import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/firebase/database_service.dart';
import '../../../../core/firebase/storage_service.dart';
import '../../../../core/services/media_service.dart';
import '../models/message_model.dart';

import '../../../../core/firebase/firebase_keys.dart';
import '../../../../core/helpers/my_logger.dart';

class MessagesRepo {
  final DatabaseService _database;
  final MediaService _mediaService;
  final StorageService _storageService;

  MessagesRepo(this._database, this._mediaService, this._storageService);

  Future<List<MessageModel>> getMessagesPage(
    String chatId, {
    int limit = 25,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      final String path =
          '${FirebaseKeys.chatsCollection}/$chatId/${FirebaseKeys.messagesCollection}';

      final snapshot = await _database.getCollection(
        path: path,
        queryBuilder: (query) {
          var configuredQuery = query.orderBy(
            FirebaseKeys.timeSent,
            descending: true,
          );
          if (lastDoc != null) {
            configuredQuery = configuredQuery.startAfterDocument(lastDoc);
          }
          return configuredQuery.limit(limit);
        },
      );
      return snapshot.docs
          .map((doc) => MessageModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      MyLogger.red('Error getting messages page: $e');
      rethrow;
    }
  }

  Stream<List<MessageModel>> getNewMessagesStream(
    String chatId,
    DateTime lastVisible,
  ) {
    try {
      final String path =
          '${FirebaseKeys.chatsCollection}/$chatId/${FirebaseKeys.messagesCollection}';
      final timestamp = Timestamp.fromDate(lastVisible);

      return _database
          .getCollectionStream(
            path: path,
            queryBuilder: (query) => query
                .orderBy(FirebaseKeys.timeSent, descending: false)
                .where(FirebaseKeys.timeSent, isGreaterThan: timestamp),
          )
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MessageModel.fromSnapshot(doc))
                .toList();
          });
    } catch (e) {
      MyLogger.red('Error getting new messages stream: $e');
      rethrow;
    }
  }

  /// Sends a message and updates the parent chat document atomically using a batch write.
  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      await _database.runBatch((batch, firestore) {
        // Reference to the parent chat document
        final chatRef = firestore.doc(
          '${FirebaseKeys.chatsCollection}/$chatId',
        );

        // Reference for the new message document in the subcollection
        final newMessageRef = chatRef
            .collection(FirebaseKeys.messagesCollection)
            .doc();

        final messageData = message.toJson();
        messageData[FirebaseKeys.uid] = newMessageRef.id;

        // Operation 1: Set the new message data
        batch.set(newMessageRef, messageData);

        // Operation 2: Update the parent chat document with the latest message info
        batch.update(chatRef, {
          FirebaseKeys.lastMessageContent: message.content,
          FirebaseKeys.lastMessageType: message.type,
          FirebaseKeys.lastActive: message.timeSent,
        });
      });
    } catch (e) {
      MyLogger.red('Error sending message in MessagesRepo: $e');
      rethrow;
    }
  }

  Future<PlatformFile> pickImageFromLibrary() async {
    try {
      final PlatformFile? file = await _mediaService.pickImageFromLibrary();
      if (file != null) {
        return file;
      } else {
        throw Exception('No image selected');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadImageToStorage(String chatId, PlatformFile file) async {
    try {
      final String? imageUrl = await _storageService.uploadChatImage(
        chatId,
        File(file.path!),
      );
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }
}
