import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:message_me/core/firebase/auth_service.dart';
import 'package:message_me/features/auth/data/repo/auth_repo.dart';

import '../../features/auth/logic/auth_cubit/auth_cubit.dart';
import '../firebase/database_service.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(firebaseAuth));
  getIt.registerLazySingleton<DatabaseService>(
    () => DatabaseService(firestore),
  );

  // Repos
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(getIt(), getIt()));

  // Cubits
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt()));
}
