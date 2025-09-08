import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../data/models/chat_model.dart';
import '../../data/repo/chats_repo.dart';

import '../../../../core/services/dependency_injection_service.dart';
import 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final ChatsRepo _chatsRepo;
  final AuthCubit _authCubit = getIt<AuthCubit>();
  final NotificationService _notificationService = getIt<NotificationService>();

  StreamSubscription? _chatStream;
  StreamSubscription? _notificationStream;

  ChatsCubit(this._chatsRepo) : super(ChatsInitial()) {
    _listenForNewMessages();
  }

  @override
  Future<void> close() {
    _chatStream?.cancel();
    _notificationStream?.cancel();
    return super.close();
  }

  void loadChats() async {
    emit(ChatsLoading());
    final String? uid = _authCubit.currentUser?.uid;
    if (uid == null) {
      MyLogger.red('User is not logged in to load chats');
      return;
    }
    // Cancel any previous subscription to avoid multiple listeners
    _chatStream?.cancel();

    try {
      _chatStream = _chatsRepo
          .getUserChats(uid)
          .listen(
            (chats) {
              emit(ChatsLoaded(chats));
              // MyLogger.green('Loaded Chats: ${chats.length}');
            },
            onError: (error) {
              emit(ChatsError('Failed to load chats'));
              MyLogger.red('Error loading Chats in Stream: $error');
            },
          );
    } catch (e) {
      MyLogger.red('Error loading Chats: $e');
      emit(ChatsError('Failed to load chats'));
    }
  }

  void _listenForNewMessages() {
    _notificationStream = _notificationService.newMessageStream.listen((
      chatId,
    ) {
      MyLogger.cyan(
        'ChatsCubit received new message notification for chat: $chatId',
      );

      // Check if the current state has chats loaded
      if (state is ChatsLoaded) {
        final currentState = state as ChatsLoaded;
        final List<ChatModel> currentChats = List.from(currentState.chats);

        // Find the index of the chat to update
        final int chatIndex = currentChats.indexWhere(
          (chat) => chat.uid == chatId,
        );

        if (chatIndex != -1) {
          // Create a new instance of the chat model with the unread flag
          currentChats[chatIndex] = currentChats[chatIndex].copyWith(
            hasUnreadMessage: true,
          );

          // Emit a new state with the updated list to trigger a UI rebuild
          emit(ChatsLoaded(currentChats));
        }
      }
    });
  }

  void markChatAsRead(String chatId) {
    if (state is ChatsLoaded) {
      final currentState = state as ChatsLoaded;
      final List<ChatModel> currentChats = List.from(currentState.chats);
      final int chatIndex = currentChats.indexWhere(
        (chat) => chat.uid == chatId,
      );

      // Only update if it was marked as unread
      if (chatIndex != -1 && currentChats[chatIndex].hasUnreadMessage) {
        currentChats[chatIndex] = currentChats[chatIndex].copyWith(
          hasUnreadMessage: false,
        );
        emit(ChatsLoaded(currentChats));
      }
    }
  }
}
