import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:message_me/core/models/user_model.dart';
import 'package:message_me/core/services/media_service.dart';

import '../../../../core/firebase/auth_service.dart';
import '../../../../core/firebase/database_service.dart';
import '../../../../core/firebase/storage_service.dart';
import '../../../../core/helpers/my_logger.dart';

class AuthRepo {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final MediaService _mediaService;

  AuthRepo(
    this._authService,
    this._databaseService,
    this._storageService,
    this._mediaService,
  );

  void setupAuthStateListener(void Function(User?) onAuthStateChanged) {
    _authService.setupAuthStateListener(onAuthStateChanged);
  }

  Future<String?> login(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    return 'Login Successful';
  }

  Future<String?> register(String email, String password) async {
    try {
      final userCredential = await _authService
          .registerUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        return userCredential.user!.uid;
      } else {
        throw Exception('Couldn\'t get user credentials');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _databaseService.getUser(userId);
      if (doc != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String> createUser(String uid, UserModel userModel) async {
    try {
      await _databaseService.addUser(uid, userModel.toJson());
      return uid;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadUserImage(String uid, PlatformFile file) async {
    try {
      final String imageUrl = await _storageService.uploadUserImage(
        uid,
        File(file.path!),
      );
      return imageUrl;
    } catch (e) {
      MyLogger.red('Error uploading user image: $e');
      rethrow;
    }
  }

  Future<PlatformFile> pickImageFromLibrary() async {
    try {
      final PlatformFile? file = await _mediaService.pickImageFromLibrary();
      if (file != null) {
        return file;
      } else {
        throw Exception('No image selected');
      }
    } catch (e) {
      rethrow;
    }
  }
}
