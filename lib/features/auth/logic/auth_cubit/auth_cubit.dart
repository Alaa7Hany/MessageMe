import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import '../../../../core/firebase/notification_service.dart';
import '../../../../core/helpers/my_logger.dart';
import '../../../../core/models/user_model.dart';

import '../../data/repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  // this flag to track the registration process
  bool _isRegistering = false;

  UserModel? currentUser;

  AuthCubit(this._authRepo) : super(AuthInitial()) {
    // logout();
    setupAuthStateListener();
  }

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _initializeNotifications(String userId) async {
    try {
      final notificationService = getIt<NotificationService>();
      await notificationService.initNotifications();
      await notificationService.saveTokenToDatabase(userId);
      MyLogger.green(
        "Notification service initialized and token saved for user: $userId",
      );
    } catch (e) {
      MyLogger.red("Failed to initialize notification service: $e");
    }
  }

  void setupAuthStateListener() {
    emit(AuthLoading());
    _authRepo.setupAuthStateListener((user) async {
      if (_isRegistering) {
        // Skip processing auth state changes during registration
        return;
      }
      if (user != null) {
        MyLogger.yellow("User is logged in");
        try {
          UserModel? userModel = await _authRepo.getUser(user.uid);
          if (userModel != null) {
            currentUser = userModel;
            emit(AuthLoginSuccess("Login Successful"));
            MyLogger.cyan("Current User: ${userModel.name}");

            await _initializeNotifications(user.uid);
          } else {
            await logout();
            MyLogger.red("Error: User data not found, logging out.");
          }
        } catch (e) {
          await logout();
          MyLogger.red("Error fetching user data: $e");
        }
      } else {
        currentUser = null;
        MyLogger.red("User is logged out");
        emit(AuthInitial());
      }
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepo.login(email, password);
    } on FirebaseAuthException {
      emit(AuthError("Invalid email or password"));
    } catch (e) {
      emit(AuthError(e.toString()));
      MyLogger.red("Error logging in user: $e");
    }
  }

  Future<void> registerUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    PlatformFile? imageFile,
  }) async {
    //Steps:
    //1. Create user with email and password
    //2. Upload image to storage
    //3. create usermodel
    //4. Save user data to Firestore
    emit(AuthLoading());
    _isRegistering = true;
    try {
      String? uid = await _authRepo.register(email, password);
      if (uid != null) {
        // upload image and get url if image is not null
        String imageUrl = '';
        if (imageFile != null) {
          imageUrl = await _authRepo.uploadUserImage(uid, imageFile) ?? '';
        }

        // create UserModel
        UserModel userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          nameToLowercase: name.toLowerCase(),
          lastActive: DateTime.now(),
          imageUrl: imageUrl,
        );
        // save data to Firestore
        await _authRepo.createUser(uid, userModel);
        currentUser = userModel;
        emit(AuthLoginSuccess("Registration Successful"));
        MyLogger.cyan("New User Registered & Logged In: ${userModel.name}");
        await _initializeNotifications(uid);
      } else {
        emit(AuthError("Registration failed"));
        MyLogger.red("Error: UID is null after registration");
        return;
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError("Email is already in use"));
      MyLogger.red("Error registering user: $e");
    } on FirebaseException catch (e) {
      emit(AuthError("Error uploading image"));
      MyLogger.red("Error uploading image: $e");
    } catch (e) {
      emit(AuthError(e.toString()));
      MyLogger.red("Error registering user: $e");
    } finally {
      //resetting the flag
      _isRegistering = false;
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await updateUserStatus(false);
    await _authRepo.signOut();
    emit(AuthLoggedOut());
  }

  Future<PlatformFile?> pickImage() async {
    try {
      return await _authRepo.pickImageFromLibrary();
    } catch (e) {
      MyLogger.red("Error picking image: $e");
      return null;
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    if (currentUser != null) {
      try {
        await _authRepo.updateUserStatus(currentUser!.uid, isOnline);
        MyLogger.cyan("User is now ${isOnline ? 'online' : 'offline'}");
      } catch (e) {
        MyLogger.red("Error updating online status: $e");
      }
    }
  }
}
