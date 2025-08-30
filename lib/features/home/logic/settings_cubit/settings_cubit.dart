import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_me/core/extensions/chat_model_presenter.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/features/auth/data/repo/auth_repo.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/features/home/data/models/chat_model.dart';
import 'package:message_me/features/home/data/repo/chats_repo.dart';

import '../../../../core/firebase/firebase_keys.dart';
import '../../../../core/models/user_model.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AuthRepo _authRepo;
  final ChatsRepo _chatsRepo;
  final bool isGroupSettings;
  final ChatModel? chatModel;
  SettingsCubit(
    this._authRepo,
    this._chatsRepo, {
    this.isGroupSettings = false,
    this.chatModel,
  }) : super(SettingsInitial()) {
    loadSettings();
    nameController.addListener(_setControllerListener);
  }
  static SettingsCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthCubit _authCubit = getIt<AuthCubit>();

  dynamic currentSubject;
  bool isImageEdited = false;
  bool isNameEdited = false;
  PlatformFile? imageFile;

  void loadSettings() {
    emit(SettingsLoading());
    formKey.currentState?.reset();
    currentSubject = isGroupSettings ? chatModel : _authCubit.currentUser;
    nameController.text = isGroupSettings
        ? chatModel!.getChatTitle(_authCubit.currentUser!.uid)
        : currentSubject!.name;
    imageFile = null;
    isImageEdited = false;
    isNameEdited = false;

    emit(SettingsLoaded());
    MyLogger.cyan(
      "Settings loaded: ${currentSubject?.name}, ${currentSubject?.imageUrl}",
    );
  }

  void updateUserData() async {
    if (!isUpdateable) return;

    emit(SettingsLoading());

    try {
      final Map<String, dynamic> dataToUpdate = {};
      final String newName = nameController.text;

      if (isImageEdited && imageFile != null) {
        final String? newImageUrl = isGroupSettings
            ? await _chatsRepo.uploadChatImage(currentSubject!.uid, imageFile!)
            : await _authRepo.uploadUserImage(currentSubject!.uid, imageFile!);
        if (newImageUrl != null) {
          dataToUpdate[FirebaseKeys.imageUrl] = newImageUrl;
        }
      }

      if (isNameEdited) {
        dataToUpdate[FirebaseKeys.name] = newName;
      }

      if (dataToUpdate.isNotEmpty) {
        if (isGroupSettings) {
          await _chatsRepo.updateChat(chatModel!.uid, dataToUpdate);
        } else {
          await _authRepo.updateUser(currentSubject!.uid, dataToUpdate);
        }
        if (dataToUpdate.containsKey(FirebaseKeys.name)) {
          currentSubject!.name = dataToUpdate[FirebaseKeys.name];
        }
        if (dataToUpdate.containsKey(FirebaseKeys.imageUrl)) {
          currentSubject!.imageUrl = dataToUpdate[FirebaseKeys.imageUrl];
        }
        MyLogger.cyan("Data updated successfully: $dataToUpdate");
      }

      emit(SettingsUpdated("Settings updated successfully"));

      loadSettings();
    } on Exception catch (e) {
      emit(SettingsError("Error updating settings"));
      MyLogger.red('Error updating settings: ${e.toString()}');
    }
  }

  void _setControllerListener() {
    if (nameController.text != currentSubject!.name) {
      isNameEdited = true;
      emit(SettingsEditedData());
    } else {
      isNameEdited = false;
      emit(SettingsEditedData());
    }
  }

  void pickImage() async {
    try {
      PlatformFile imageFile = await _authRepo.pickImageFromLibrary();
      this.imageFile = imageFile;
      emit(SettingsEditedData());
      isImageEdited = true;
    } catch (e) {
      MyLogger.red('Error picking image: ${e.toString()}');
      emit(SettingsError("Error picking image"));
    }
  }

  bool get isUpdateable {
    final isFormValid = formKey.currentState?.validate() ?? false;
    return isFormValid && (isNameEdited || isImageEdited);
  }

  bool get isResetable {
    return isNameEdited || isImageEdited;
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}
