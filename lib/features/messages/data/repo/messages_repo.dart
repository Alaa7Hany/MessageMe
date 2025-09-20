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

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    try {
      final String path =
          '${FirebaseKeys.chatsCollection}/$chatId/${FirebaseKeys.messagesCollection}';
      return _database
          .getCollectionStream(
            path: path,
            queryBuilder: (query) =>
                query.orderBy(FirebaseKeys.timeSent, descending: true),
          )
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => MessageModel.fromSnapshot(doc))
                .toList(),
          );
    } catch (e) {
      MyLogger.red('Error getting messages stream: $e');
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
        messageData[FirebaseKeys.timeSent] = FieldValue.serverTimestamp();

        // Operation 1: Set the new message data
        batch.set(newMessageRef, messageData);

        // Operation 2: Update the parent chat document with the latest message info
        batch.update(chatRef, {
          FirebaseKeys.lastMessageContent: message.content,
          FirebaseKeys.lastMessageType: message.type,
          FirebaseKeys.lastActive: FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      MyLogger.red('Error sending message in MessagesRepo: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(
    String chatId,
    List<String> messageIds,
    String userId,
  ) async {
    if (messageIds.isEmpty) return;
    try {
      await _database.runBatch((batch, firestore) {
        final now = FieldValue.serverTimestamp();
        for (final messageId in messageIds) {
          final messageRef = firestore.doc(
            '${FirebaseKeys.chatsCollection}/$chatId/${FirebaseKeys.messagesCollection}/$messageId',
          );
          batch.update(messageRef, {'${FirebaseKeys.readBy}.$userId': now});
        }
        // final chatRef = firestore.doc(
        //   '${FirebaseKeys.chatsCollection}/$chatId',
        // );
        // batch.update(chatRef, {'${FirebaseKeys.unreadCounts}.$userId': 0});
      });
    } catch (e) {
      MyLogger.red('Error marking messages as read in batch: $e');
      // No rethrow, as this is not a critical UI-blocking error
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

  Future<void> reactToMessage({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction, // The emoji
  }) async {
    try {
      final messagePath =
          '${FirebaseKeys.chatsCollection}/$chatId/${FirebaseKeys.messagesCollection}/$messageId';

      // If the reaction is empty, we remove the user's reaction.
      // Otherwise, we set/update it.
      if (reaction.isEmpty) {
        await _database.updateData(
          path: messagePath,
          data: {'${FirebaseKeys.reactions}.$userId': FieldValue.delete()},
        );
      } else {
        await _database.updateData(
          path: messagePath,
          data: {'${FirebaseKeys.reactions}.$userId': reaction},
        );
      }
    } catch (e) {
      MyLogger.red('Error reacting to message: $e');
      rethrow;
    }
  }
}
