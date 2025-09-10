import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/my_logger.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../data/repo/chats_repo.dart';
import '../../../../core/services/dependency_injection_service.dart';
import 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final ChatsRepo _chatsRepo;
  final AuthCubit _authCubit = getIt<AuthCubit>();

  StreamSubscription? _chatStream;

  StreamSubscription? _tickerSubscription;

  ChatsCubit(this._chatsRepo) : super(ChatsInitial()) {
    _startTicker();
  }

  @override
  Future<void> close() {
    _chatStream?.cancel();
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _startTicker() {
    // This stream will emit a value every minute.
    _tickerSubscription = Stream.periodic(const Duration(minutes: 1)).listen((
      _,
    ) {
      // When the ticker fires, we check if we have chats loaded.
      loadChats();
    });
  }

  void loadChats() async {
    // This check is important. We only load chats if a user is logged in.
    final String? uid = _authCubit.currentUser?.uid;
    if (uid == null) {
      // Don't emit loading, just return silently.
      // The UI will show 'No messages yet' or a similar state.
      return;
    }

    // Only show the full loading spinner on the first load.
    if (state is! ChatsLoaded) {
      emit(ChatsLoading());
    }

    _chatStream?.cancel(); // Cancel previous subscription to avoid leaks.

    try {
      _chatStream = _chatsRepo
          .getUserChats(uid)
          .listen(
            (chats) {
              emit(ChatsLoaded(chats));
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

  void markChatAsRead(String chatId) {
    // We get the current user's ID.
    final String? uid = _authCubit.currentUser?.uid;
    if (uid == null) return;

    // We don't need to check the local state. We just tell the repository
    // to reset the count in the database. The real-time stream from `loadChats`
    // will automatically update the UI with the new data from Firestore.
    _chatsRepo.resetUnreadCount(chatId, uid);
  }
}
