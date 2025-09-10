import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dependency_injection_service.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';

import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repo/find_users_repo.dart';
import 'find_users_state.dart';

class FindUsersCubit extends Cubit<FindUsersState> {
  final FindUsersRepo _findUsersRepo;

  FindUsersCubit(this._findUsersRepo) : super(FindUsersInitial()) {
    _setupScrollListener();
    searchFieldController.addListener(_onSearchChanged);
  }

  ScrollController usersScrollController = ScrollController();

  TextEditingController searchFieldController = TextEditingController();
  Timer? _debounce;

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
    _debounce?.cancel();
    return super.close();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = searchFieldController.text.trim();
      if (query.isEmpty) {
        loadInitialUsers(isHardRefresh: false);
      } else {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) async {
    _users.clear();
    _lastUser = null;
    emit(
      FindUsersLoaded(
        [],
        false,
        selectedUsers: _selectedUsers,
        isSearching: true,
      ),
    );

    try {
      final results = await _findUsersRepo.searchUsers(
        searchQuery: query,
        currentUserId: _authCubit.currentUser!.uid,
        limit: limit,
      );

      // 👇 Safety check after await
      if (isClosed) return;

      _users.addAll(results);
      _hasMoreUsers = false;
      emit(
        FindUsersLoaded(
          _users,
          _hasMoreUsers,
          selectedUsers: _selectedUsers,
          isSearching: false,
        ),
      );
      MyLogger.yellow('Search results are: ${_users.length}');
    } catch (e) {
      // 👇 Safety check after await
      if (isClosed) return;
      emit(FindUsersError(e.toString()));
    }
  }

  void emitLoadedUsers() {
    MyLogger.magenta('Emitting loaded users');
    _selectedUsers.clear();
    emit(FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers));
  }

  void loadInitialUsers({bool isHardRefresh = true}) async {
    if (state is FindUsersLoading) return;

    _users.clear();
    _lastUser = null;
    _hasMoreUsers = true;
    _selectedUsers.clear();

    if (isHardRefresh) {
      emit(FindUsersLoading());
    }

    try {
      searchFieldController.clear();

      final String? uid = _authCubit.currentUser?.uid;
      if (uid == null) {
        MyLogger.red('User is not logged in to load Users');
        return;
      }
      final usersPage = await _findUsersRepo.getUsersPage(
        currentUserId: uid,
        limit: limit,
      );

      // 👇 Safety check after await
      if (isClosed) return;

      if (usersPage.isNotEmpty) {
        _lastUser = usersPage.last;
        _users.addAll(usersPage);
      }
      if (usersPage.length < limit) {
        _hasMoreUsers = false;
      }
      emit(
        FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers),
      );
      MyLogger.yellow('Loaded initial users: ${_users.length}');
    } catch (e) {
      MyLogger.red('Error loading users: $e');
      // 👇 Safety check after await
      if (isClosed) return;
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
        _isLoadingUsers = false; // Reset lock
        return;
      }

      final newUsers = await _findUsersRepo.getUsersPage(
        currentUserId: uid,
        lastUser: _lastUser,
        limit: limit,
      );

      // 👇 Safety check after await
      if (isClosed) return;

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
      // 👇 Safety check after await
      if (isClosed) return;
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

  void startChat() async {
    emit(FindUsersLoading());
    try {
      final chatModel = await _findUsersRepo.createOrGetChat(
        _authCubit.currentUser!,
        _selectedUsers,
      );

      // 👇 Safety check after await
      if (isClosed) return;

      emit(FindUsersStartChat(chatModel));
    } catch (e) {
      MyLogger.red('Error starting chat: $e');
      // 👇 Safety check after await
      if (isClosed) return;
      emit(FindUsersError('Error Starting Chat'));
      emit(
        FindUsersLoaded(_users, _hasMoreUsers, selectedUsers: _selectedUsers),
      );
    }
  }

  void searchUsers() {}
}
