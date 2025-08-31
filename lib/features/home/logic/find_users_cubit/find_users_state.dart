import '../../data/models/chat_model.dart';

import '../../../../core/models/user_model.dart';

abstract class FindUsersState {}

class FindUsersInitial extends FindUsersState {}

class FindUsersLoading extends FindUsersState {}

class FindUsersLoaded extends FindUsersState {
  final List<UserModel> users;
  final bool hasMoreUsers;
  final List<UserModel> selectedUsers;
  final bool isSearching;

  FindUsersLoaded(
    this.users,
    this.hasMoreUsers, {
    required this.selectedUsers,
    this.isSearching = false,
  });
}

class FindUsersError extends FindUsersState {
  final String message;

  FindUsersError(this.message);
}

class FindUsersStartChat extends FindUsersState {
  final ChatModel chatModel;

  FindUsersStartChat(this.chatModel);
}
