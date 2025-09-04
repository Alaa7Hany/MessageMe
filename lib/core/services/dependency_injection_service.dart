import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import '../firebase/auth_service.dart';
import 'media_service.dart';
import '../../features/auth/data/repo/auth_repo.dart';
import '../../features/home/data/repo/find_users_repo.dart';

import '../../features/auth/logic/auth_cubit/auth_cubit.dart';
import '../../features/home/data/repo/chats_repo.dart';
import '../../features/messages/data/repo/messages_repo.dart';
import 'connectivity_cubit/connectivity_cubit.dart';
import '../firebase/database_service.dart';
import '../firebase/storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final MediaService mediaService = MediaService();
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(firebaseAuth));
  getIt.registerLazySingleton<DatabaseService>(
    () => DatabaseService(firestore),
  );
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(firebaseStorage),
  );
  getIt.registerLazySingleton<MediaService>(() => mediaService);

  // Repos
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<ChatsRepo>(() => ChatsRepo(getIt(), getIt()));
  getIt.registerLazySingleton<MessagesRepo>(
    () => MessagesRepo(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<FindUsersRepo>(() => FindUsersRepo(getIt()));

  // Cubits
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt()));
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());
}
