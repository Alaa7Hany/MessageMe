import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repo/find_users_repo.dart';
import 'find_users_state.dart';

class FindUsersCubit extends Cubit<FindUsersState> {
  final FindUsersRepo _findUsersRepo;

  FindUsersCubit(this._findUsersRepo) : super(FindUsersInitial()) {
    _setupScrollListener();
  }

  ScrollController usersScrollController = ScrollController();
  TextEditingController searchFieldController = TextEditingController();
  final _authCubit = getIt<AuthCubit>();

  final List<UserModel> _selectedUsers = [];

  // State for pagination
  final List<UserModel> _users = [];
  bool _hasMoreUsers = true;
  bool _isLoadingUsers = false;
  UserModel? _lastUser;
  final int limit = 20;

  void _setupScrollListener() {
    usersScrollController.addListener(() {
      // If the user scrolls to the very top of the list
      if (usersScrollController.position.pixels ==
          usersScrollController.position.maxScrollExtent) {
        _loadMoreUsers();
      }
    });
  }

  @override
  Future<void> close() {
    usersScrollController.dispose();
    searchFieldController.dispose();
    return super.close();
  }

  void loadInitialUsersPage() async {
    emit(FindUsersLoading());
    try {
      final String? uid = _authCubit.currentUser?.uid;
      if (uid == null) {
        MyLogger.red('User is not logged in to load Users');
        return;
      }
      final usersPage = await _findUsersRepo.getUsersPage(
        currentUserId: uid,
        limit: limit,
      );
      if (usersPage.isNotEmpty) {
        _lastUser = usersPage.last;
        _users.addAll(usersPage);
      }
      if (_users.length < limit) {
        _hasMoreUsers = false;
      }
      emit(
        FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers),
      );
    } catch (e) {
      MyLogger.red('Error loading users: $e');
      emit(FindUsersError(e.toString()));
    }
  }

  void _loadMoreUsers() async {
    try {
      if (!_hasMoreUsers || _isLoadingUsers) return;
      _isLoadingUsers = true;
      final String? uid = _authCubit.currentUser?.uid;
      if (uid == null) {
        MyLogger.red('User is not logged in to load Users');
        return;
      }

      final newUsers = await _findUsersRepo.getUsersPage(
        currentUserId: uid,
        lastUser: _lastUser,
        limit: limit,
      );
      if (newUsers.isNotEmpty) {
        _lastUser = newUsers.last;
        _users.addAll(newUsers);
      }
      if (newUsers.length < limit) {
        _hasMoreUsers = false;
      }
      emit(
        FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers),
      );
      _isLoadingUsers = false;
    } catch (e) {
      _isLoadingUsers = false;
      MyLogger.red('Error loading more users: $e');
      emit(
        FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers),
      );
    }
  }

  void selectUser(UserModel user) {
    _selectedUsers.add(user);
    emit(FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers));
  }

  void unselectUser(UserModel user) {
    _selectedUsers.remove(user);
    emit(FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers));
  }

  void startPrivateChat(UserModel user) {
    emit(FindUsersStartPrivateChat(user));
  }

  void startGroupChat(List<UserModel> users) {
    emit(FindUsersStartGroupChat(users));
  }

  void searchUsers() {}
}
