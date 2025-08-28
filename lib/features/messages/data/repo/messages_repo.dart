import 'package:message_me/core/firebase/database_service.dart';
import 'package:message_me/features/messages/data/models/message_model.dart';

import '../../../../core/helpers/my_logger.dart';

class MessagesRepo {
  final DatabaseService _database;

  MessagesRepo(this._database);

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    try {
      return _database.getChatMessages(chatId).map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromJson(doc.data());
        }).toList();
      });
    } catch (e) {
      MyLogger.red('Error loading chat messages in MessagesRepo: $e');
      rethrow;
    }
  }
}
