import '../../data/models/message_model.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesSending extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;
  final bool hasMore;

  MessagesLoaded(this.messages, {this.hasMore = true});
}

class MessagesError extends MessagesState {
  final String message;

  MessagesError(this.message);
}
