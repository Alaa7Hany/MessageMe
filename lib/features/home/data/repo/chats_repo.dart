import 'dart:async';

import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/models/user_model.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';

class ChatsRepo {
  final DatabaseService _databaseService;

  ChatsRepo(this._databaseService);

  // Here We convert the stream of QuerySnapshot to List<ChatModel>
  Stream<List<ChatModel>> getUserChats(String uid) {
    try {
      return _databaseService.getUserChats(uid).asyncMap((querySnapshot) async {
        // 2. Map each document to a Future that will resolve to a ChatModel.
        final chatFutures = querySnapshot.docs.map((doc) async {
          final chatData = doc.data();
          final chat = ChatModel.fromJson(chatData);
          chat.uid = doc.id; // Assign the document ID to uid

          // 3. 'await' is now valid inside this async callback.
          chat.membersModels = await getChatMembers(chat.uid, chat.membersIds);

          return chat;
        }).toList();

        // 4. Wait for all the member-fetching operations to complete.
        return await Future.wait(chatFutures);
      });
    } catch (e) {
      MyLogger.red('Error loading user chats in ChatsRepo: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getChatMembers(
    String chatId,
    List<String> memberIds,
  ) async {
    try {
      List<UserModel> members = [];
      for (var memberId in memberIds) {
        final user = await getOneChatMember(chatId, memberId);
        members.add(user);
      }
      return members;
    } catch (e) {
      MyLogger.red('Error getting chat members in ChatsRepo: $e');
      rethrow;
    }
  }

  Future<UserModel> getOneChatMember(String chatId, String userId) async {
    try {
      final userDoc = await _databaseService.getUser(userId);
      if (userDoc == null) {
        throw Exception('User not found');
      }
      final userData = userDoc.data() as Map<String, dynamic>;

      return UserModel.fromJson(userData);
    } catch (e) {
      MyLogger.red('Error getting chat member in ChatsRepo: $e');
      rethrow;
    }
  }
}
