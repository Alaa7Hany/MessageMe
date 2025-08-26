import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/models/user_model.dart';

import '../../data/repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  UserModel? currentUser;

  AuthCubit(this._authRepo) : super(AuthInitial()) {
    // logout();
    setupAuthStateListener();
  }

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepo.signIn(email, password);
    } on FirebaseAuthException {
      emit(AuthError("Invalid email or password"));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void setupAuthStateListener() {
    _authRepo.setupAuthStateListener((user) async {
      if (user != null) {
        MyLogger.yellow("User is logged in");
        try {
          UserModel? userModel = await _authRepo.getUser(user.uid);
          if (userModel != null) {
            currentUser = userModel;
            emit(AuthLoginSuccess("Login Successful"));
            MyLogger.cyan("Current User: ${userModel.name}");
          } else {
            emit(AuthError("User data not found"));
          }
        } catch (e) {
          emit(AuthError("Error fetching user data: $e"));
        }
      } else {
        currentUser = null;
        MyLogger.red("User is logged out");
        emit(AuthInitial());
      }
    });
  }

  void togglePasswordVisibility() {
    emit(
      AuthTogglePasswordVisibility(
        !(state is AuthTogglePasswordVisibility &&
            (state as AuthTogglePasswordVisibility).isVisible),
      ),
    );
  }

  void logout() {
    _authRepo.signOut();
  }
}
