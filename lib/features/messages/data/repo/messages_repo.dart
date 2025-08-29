import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/firebase/storage_service.dart';
import 'package:message_me/core/services/media_service.dart';
import 'package:message_me/features/messages/data/models/message_model.dart';

import '../../../../core/firebase/firebase_keys.dart';
import '../../../../core/helpers/my_logger.dart';

class MessagesRepo {
  final DatabaseService _database;
  final MediaService _mediaService;
  final StorageService _storageService;

  MessagesRepo(this._database, this._mediaService, this._storageService);

  Future<List<MessageModel>> getMessagesPage(
    String chatId, {
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      final snapshot = await _database.getMessagesPage(
        chatId,
        lastMessageDoc: lastDoc,
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
      // Convert DateTime to Firestore Timestamp for the query
      final timestamp = Timestamp.fromDate(lastVisible);
      return _database.getNewMessagesStream(chatId, timestamp).map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromSnapshot(doc))
            .toList();
      });
    } catch (e) {
      MyLogger.red('Error getting new messages stream: $e');
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

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      await _database.sendChatMessageWithBatch(chatId, message.toJson());
    } catch (e) {
      MyLogger.red('Error sending message in MessagesRepo: $e');
      rethrow;
    }
  }
}
