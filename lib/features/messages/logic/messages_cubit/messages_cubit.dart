import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';
import '../../../home/logic/chats_cubit/chats_cubit.dart';
import '../../data/models/message_model.dart';
import '../../data/repo/messages_repo.dart';
import '../services/message_sending_service.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final List<MessageModel> _messages = [];
  DocumentSnapshot? _lastMessageDoc;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  final MessagesRepo _messagesRepo;
  StreamSubscription? _messagesSubscription;
  final ChatModel chatModel;
  final UserModel currentUser = getIt<AuthCubit>().currentUser!;

  // The new service for sending messages
  late final MessageSendingService _sendingService;

  MessagesCubit(this._messagesRepo, this.chatModel) : super(MessagesInitial()) {
    // Initialize the service in the constructor
    _sendingService = MessageSendingService(
      messagesRepo: _messagesRepo,
      chatId: chatModel.uid,
      currentUser: currentUser,
    );
    _loadInitialMessages();
    _setupScrollListener();
  }

  static MessagesCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController messageController = TextEditingController();
  final ScrollController messagesListViewController = ScrollController();

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    messagesListViewController.dispose();

    return super.close();
  }

  ////////////////////////////////////////////// Sending Messages //////////////////////////////////////////////

  void _updateMessageStatus(String tempId, MessageStatus status) {
    final messageIndex = _messages.indexWhere((m) => m.uid == tempId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        status: status,
      );
      // Emit the state to update the UI
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    }
  }

  void sendTextMessage() {
    final String text = messageController.text.trim();
    if (text.isEmpty) return;

    final (tempMessage, sendFuture) = _sendingService.sendTextMessage(text);

    // 1. Immediately update UI
    messageController.clear();
    _messages.insert(0, tempMessage);
    emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    scrollToBottom();

    // 2. Handle the result of the future in the background
    sendFuture.catchError((error) {
      MyLogger.red('Failed to send text message: $error');
      _updateMessageStatus(tempMessage.uid!, MessageStatus.failed);
    });
  }

  void sendImage() async {
    try {
      // The service now handles file picking, so we await the result.
      final (tempMessage, sendFuture) = await _sendingService.sendImage();

      // 1. Immediately update UI
      _messages.insert(0, tempMessage);
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
      scrollToBottom();

      // 2. Handle the result
      sendFuture.catchError((error) {
        MyLogger.red('Failed to send image message: $error');
        _updateMessageStatus(tempMessage.uid!, MessageStatus.failed);
      });
    } catch (e) {
      // This catch is for errors during file picking (e.g., user cancels)
      MyLogger.yellow('Image picking cancelled or failed: $e');
    }
  }
  ////////////////////////////////////////// Pagination and Real-time Updates //////////////////////////////////////////

  void updateChatData() {
    emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messagesListViewController.hasClients) {
        messagesListViewController.jumpTo(0.0);
      }
    });
  }

  void _loadInitialMessages() async {
    emit(MessagesLoading());
    try {
      final messagesPage = await _messagesRepo.getMessagesPage(chatModel.uid);
      if (messagesPage.isNotEmpty) {
        _lastMessageDoc = messagesPage.last.rawDoc;
        _messages.addAll(messagesPage);
      }
      _listenForNewMessages();
      if (messagesPage.length < 25) {
        _hasMoreMessages = false;
      }
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    } catch (e) {
      MyLogger.red('Error loading initial messages: $e');
      emit(MessagesError(e.toString()));
    }
  }

  void _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;
    _isLoadingMore = true;
    emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    try {
      final messagesPage = await _messagesRepo.getMessagesPage(
        chatModel.uid,
        lastDoc: _lastMessageDoc,
      );
      if (messagesPage.length < 25) {
        _hasMoreMessages = false;
      }
      if (messagesPage.isNotEmpty) {
        _lastMessageDoc = messagesPage.last.rawDoc;
        _messages.addAll(messagesPage);
      }
      _isLoadingMore = false;
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    } catch (e) {
      _isLoadingMore = false;
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    }
  }

  void _listenForNewMessages() {
    try {
      final startTime = _messages.isNotEmpty
          ? _messages.first.timeSent
          : DateTime.now();
      _messagesSubscription?.cancel();
      _messagesSubscription = _messagesRepo
          .getNewMessagesStream(chatModel.uid, startTime)
          .listen(
            (newMessages) async {
              if (newMessages.isEmpty) return;
              bool wereMessagesAdded = false;
              for (final message in newMessages.reversed) {
                final tempMessageIndex = _messages.indexWhere(
                  (m) =>
                      m.status == MessageStatus.sending &&
                      m.uid == message.tempId,
                );
                if (tempMessageIndex != -1) {
                  _messages[tempMessageIndex] = message.copyWith(
                    status: MessageStatus.sent,
                  );
                  wereMessagesAdded = true;
                  MyLogger.green('Message reconciled: ${message.content}');
                } else if (!_messages.any((m) => m.uid == message.uid)) {
                  _messages.insert(0, message);
                  wereMessagesAdded = true;
                  MyLogger.yellow('New message added: ${message.content}');
                }
              }
              _messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
              if (wereMessagesAdded) {
                emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
              }
            },
            onError: (error) {
              MyLogger.red('Error listening for new messages: $error');
            },
          );
    } catch (e) {
      MyLogger.red('Error initiating Stream $e');
    }
  }

  void _setupScrollListener() {
    messagesListViewController.addListener(() {
      if (messagesListViewController.position.pixels ==
          messagesListViewController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
  }
}
