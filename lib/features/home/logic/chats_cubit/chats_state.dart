import '../../data/models/chat_model.dart';

abstract class ChatsState {}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatModel> chats;

  ChatsLoaded(this.chats);
}

class ChatsError extends ChatsState {
  final String message;

  ChatsError(this.message);
}
