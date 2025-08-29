import 'dart:async';

import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/models/user_model.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';
import 'package:message_me/core/firebase/firebase_keys.dart'; // Make sure this import exists

class ChatsRepo {
  final DatabaseService _databaseService;

  ChatsRepo(this._databaseService);

  /// Converts a stream of QuerySnapshots into a stream of List of ChatModel.
  Stream<List<ChatModel>> getUserChats(String uid) {
    try {
      return _databaseService
          .getCollectionStream(
            path: FirebaseKeys.chatsCollection,
            queryBuilder: (query) => query
                .where(FirebaseKeys.members, arrayContains: uid)
                .orderBy(FirebaseKeys.lastActive, descending: true),
          )
          .asyncMap((querySnapshot) async {
            final chatFutures = querySnapshot.docs.map((doc) async {
              final chatData = doc.data();
              final chat = ChatModel.fromJson(chatData);
              chat.uid = doc.id;
              chat.membersModels = await _getChatMembers(
                chat.uid,
                chat.membersIds,
              );

              return chat;
            }).toList();

            return await Future.wait(chatFutures);
          });
    } catch (e) {
      MyLogger.red('Error loading user chats in ChatsRepo: $e');
      rethrow;
    }
  }

  /// Fetches the UserModel for each member ID in a chat.
  Future<List<UserModel>> _getChatMembers(
    String chatId,
    List<String> memberIds,
  ) async {
    try {
      List<UserModel> members = [];
      for (var memberId in memberIds) {
        final user = await _getOneChatMember(chatId, memberId);
        members.add(user);
      }
      return members;
    } catch (e) {
      MyLogger.red('Error getting chat members in ChatsRepo: $e');
      rethrow;
    }
  }

  /// Fetches a single user's profile.
  Future<UserModel> _getOneChatMember(String chatId, String userId) async {
    try {
      final userDoc = await _databaseService.getDocument(
        path: '${FirebaseKeys.usersCollection}/$userId',
      );

      if (!userDoc.exists) {
        throw Exception('User not found: $userId');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      MyLogger.red('Error getting chat member in ChatsRepo: $e');
      rethrow;
    }
  }
}
