import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';
import 'package:message_me/features/messages/data/models/message_model.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repo/messages_repo.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
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
        _lastMessageDoc = messagesPage
            .last
            .rawDoc; // Assuming your model can hold the raw doc
        _messages.addAll(messagesPage);
        _listenForNewMessages(); // Start listening for new messages ONLY after the first page is loaded
      }
      emit(
        MessagesLoaded(
          _messages,
          hasMore: _hasMoreMessages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  void loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    _isLoadingMore = true;
    emit(
      MessagesLoaded(_messages, hasMore: _hasMoreMessages, isLoadingMore: true),
    );

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
      emit(
        MessagesLoaded(
          _messages,
          hasMore: _hasMoreMessages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Handle error, maybe emit an error state
      _isLoadingMore = false;
      emit(
        MessagesLoaded(
          _messages,
          hasMore: _hasMoreMessages,
          isLoadingMore: false,
        ),
      );
    }
  }

  void _listenForNewMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _messagesRepo
        .getNewMessagesStream(chatModel.uid, _messages.first.timeSent)
        .listen((newMessages) {
          // Add new messages to the beginning of the list (since it's reversed in UI)
          _messages.insertAll(0, newMessages);
          emit(
            MessagesLoaded(
              _messages,
              hasMore: _hasMoreMessages,
              isLoadingMore: false,
            ),
          );
          scrollToBottom();
        });
  }

  void _setupScrollListener() {
    messagesListViewController.addListener(() {
      // If the user scrolls to the very top of the list
      if (messagesListViewController.position.pixels ==
          messagesListViewController.position.maxScrollExtent) {
        loadMoreMessages();
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
