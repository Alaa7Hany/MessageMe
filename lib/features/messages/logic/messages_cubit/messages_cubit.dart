import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';
import '../../data/models/message_model.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repo/messages_repo.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  // Pagination Guide
  // 1. load initial messages and store them in list _messages
  // 2. put a bookmark on the last message loaded
  // 3. load more messages when scrolling to the top
  // 4. listen for new messages and add them to the _messages list

  // --- State for Pagination ---
  final List<MessageModel> _messages = [];
  DocumentSnapshot? _lastMessageDoc;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  final MessagesRepo _messagesRepo;
  StreamSubscription? _messagesSubscription;
  final ChatModel chatModel;
  final UserModel currentUser = getIt<AuthCubit>().currentUser!;
  MessagesCubit(this._messagesRepo, this.chatModel) : super(MessagesInitial()) {
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

  void updateChatData() {
    emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
  }

  void scrollToBottom() {
    // We use a post-frame callback to ensure the list has been built
    // before we try to scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messagesListViewController.hasClients) {
        messagesListViewController.jumpTo(
          0.0,
        ); // Jump to the very bottom (0.0 because the list is reversed)
      }
    });
  }

  void _loadInitialMessages() async {
    emit(MessagesLoading());
    try {
      final messagesPage = await _messagesRepo.getMessagesPage(chatModel.uid);
      if (messagesPage.isNotEmpty) {
        // saving the last Message received as a bookmark
        _lastMessageDoc = messagesPage.last.rawDoc;
        _messages.addAll(messagesPage);
      } // Start listening for new messages
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
      // Handle error, maybe emit an error state
      _isLoadingMore = false;
      emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));
    }
  }

  void _listenForNewMessages() {
    try {
      // If we have messages, start after the newest one.
      // If the chat is empty, start from the current time.
      final startTime = _messages.isNotEmpty
          ? _messages.first.timeSent
          : DateTime.now();

      _messagesSubscription?.cancel();
      _messagesSubscription = _messagesRepo
          .getNewMessagesStream(chatModel.uid, startTime)
          .listen(
            (newMessages) {
              // in the beginning of the stream, there are no messages
              if (newMessages.isEmpty) return;
              // Add new messages to the beginning of the list (since it's reversed in UI)
              _messages.insert(0, newMessages.last);
              MyLogger.yellow(
                'New message received: ${newMessages.last.content}',
              );
              emit(MessagesLoaded(_messages, hasMore: _hasMoreMessages));

              scrollToBottom();
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
      // If the user scrolls to the very top of the list
      if (messagesListViewController.position.pixels ==
          messagesListViewController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
  }

  void sendImage() async {
    try {
      final PlatformFile file = await _messagesRepo.pickImageFromLibrary();
      final String? imageUrl = await _messagesRepo.uploadImageToStorage(
        chatModel.uid,
        file,
      );
      if (imageUrl != null) {
        final MessageModel message = MessageModel(
          senderUid: currentUser.uid,
          senderImage: currentUser.imageUrl,
          senderName: currentUser.name,
          type: 'image',
          content: imageUrl,
          timeSent: DateTime.now(),
        );
        _messagesRepo.sendMessage(chatModel.uid, message);
      } else {
        MyLogger.red('Error uploading image');
      }
    } catch (e) {
      MyLogger.red('Error picking image: $e');
    }
  }

  void sendTextMessage() async {
    try {
      final String text = messageController.text.trim();
      if (text.isNotEmpty) {
        final MessageModel message = MessageModel(
          senderUid: currentUser.uid,
          senderImage: currentUser.imageUrl,
          senderName: currentUser.name,
          type: 'text',
          content: text,
          timeSent: DateTime.now(),
        );
        _messagesRepo.sendMessage(chatModel.uid, message);
        messageController.clear();
      }
    } catch (e) {
      MyLogger.red('Error sending text message: $e');
    }
  }
}
