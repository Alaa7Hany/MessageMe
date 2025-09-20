import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repo/messages_repo.dart';
import '../services/message_sending_service.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepo _messagesRepo;
  final ChatModel chatModel;
  final UserModel currentUser = getIt<AuthCubit>().currentUser!;
  late final MessageSendingService _sendingService;
  StreamSubscription? _messagesSubscription;

  MessagesCubit(this._messagesRepo, this.chatModel) : super(MessagesInitial()) {
    _sendingService = MessageSendingService(
      messagesRepo: _messagesRepo,
      chatId: chatModel.uid,
      currentUser: currentUser,
    );
    _listenForMessages();
  }

  static MessagesCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController messageController = TextEditingController();
  final ScrollController messagesListViewController = ScrollController();

  void _listenForMessages() {
    emit(MessagesLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription = _messagesRepo
        .getMessagesStream(chatModel.uid)
        .listen(
          (messages) {
            _markVisibleMessagesAsRead(messages);
            emit(MessagesLoaded(messages));
          },
          onError: (error) {
            MyLogger.red('Error in messages stream: $error');
            emit(MessagesError('Failed to load messages.'));
          },
        );
  }

  void _markVisibleMessagesAsRead(List<MessageModel> messages) {
    final unreadMessageIds = messages
        .where(
          (msg) =>
              msg.senderUid != currentUser.uid &&
              !msg.readBy.containsKey(currentUser.uid),
        )
        .map((msg) => msg.uid!)
        .toList();

    if (unreadMessageIds.isNotEmpty) {
      _messagesRepo.markMessagesAsRead(
        chatModel.uid,
        unreadMessageIds,
        currentUser.uid,
      );
    }
  }

  void reactToMessage(String messageId, String reaction) {
    final String currentUserId = currentUser.uid;
    _messagesRepo
        .reactToMessage(
          chatId: chatModel.uid,
          messageId: messageId,
          userId: currentUserId,
          reaction: reaction,
        )
        .catchError((e) {
          MyLogger.red('Failed to update reaction in Firestore: $e');
        });
  }

  void sendTextMessage() {
    final String text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    final (_, sendFuture) = _sendingService.sendTextMessage(text);
    sendFuture.catchError((error) {
      MyLogger.red('Failed to send text message: $error');
    });
  }

  void sendImage() async {
    try {
      final (_, sendFuture) = await _sendingService.sendImage();
      sendFuture.catchError((error) {
        MyLogger.red('Failed to send image message: $error');
      });
    } catch (e) {
      MyLogger.yellow('Image picking cancelled or failed: $e');
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    messagesListViewController.dispose();
    return super.close();
  }
}
