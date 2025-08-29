import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/home/data/repo/chats_repo.dart';

import '../../../../core/services/dependency_injection_service.dart';
import 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final ChatsRepo _chatsRepo;
  final AuthCubit _authCubit = getIt<AuthCubit>();

  StreamSubscription? _chatStream;

  ChatsCubit(this._chatsRepo) : super(ChatsInitial());

  @override
  Future<void> close() {
    _chatStream?.cancel();
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
}
