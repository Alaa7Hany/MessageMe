import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../data/repo/messages_repo.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepo _messagesRepo;
  StreamSubscription? _messagesSubscription;
  final ChatModel chatModel;
  MessagesCubit(this._messagesRepo, this.chatModel) : super(MessagesInitial());

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  void loadMessages() async {
    emit(MessagesLoading());
    try {
      _messagesSubscription = _messagesRepo
          .getChatMessages(chatModel.uid)
          .listen((messages) {
            emit(MessagesLoaded(messages));
            MyLogger.green(
              'Loaded ${messages.length} messages for chat ${chatModel.uid}',
            );
          });
    } catch (e) {
      emit(MessagesError(e.toString()));
      MyLogger.red('Error loading messages in MessagesCubit: $e');
    }
  }
}
