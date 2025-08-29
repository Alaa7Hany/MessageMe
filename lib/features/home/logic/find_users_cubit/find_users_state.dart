import '../../../../core/models/user_model.dart';

abstract class FindUsersState {}

class FindUsersInitial extends FindUsersState {}

class FindUsersLoading extends FindUsersState {}

class FindUsersLoaded extends FindUsersState {
  final List<UserModel> users;
  final bool hasMoreUsers;
  final List<UserModel> selectedUsers;

  FindUsersLoaded(this.users, this.hasMoreUsers, {required this.selectedUsers});
}

class FindUsersError extends FindUsersState {
  final String message;

  FindUsersError(this.message);
}

class FindUsersStartPrivateChat extends FindUsersState {
  final UserModel user;

  FindUsersStartPrivateChat(this.user);
}

class FindUsersStartGroupChat extends FindUsersState {
  final List<UserModel> users;

  FindUsersStartGroupChat(this.users);
}

class FindUsersStartChatError extends FindUsersState {
  final String message;

  FindUsersStartChatError(this.message);
}
