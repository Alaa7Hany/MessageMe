import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/helpers/my_logger.dart';
import 'package:message_me/core/helpers/text_field_validator.dart';
import 'package:message_me/core/widgets/loading_screen_overlay.dart';
import 'package:message_me/core/widgets/my_snackbar.dart';
import 'package:message_me/core/widgets/my_textform_field.dart';
import 'package:message_me/core/widgets/rounded_image.dart';
import 'package:message_me/features/home/views/widgets/user_listtile.dart';
import 'package:message_me/features/messages/logic/messages_cubit/messages_cubit.dart';

import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/my_elevated_button.dart';
import '../../logic/settings_cubit/settings_cubit.dart';
import '../../logic/settings_cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = SettingsCubit.get(context);
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          MySnackbar.error(context, state.message);
        } else if (state is SettingsUpdated) {
          MySnackbar.success(context, state.message);
          if (cubit.isGroupSettings) {
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            _buildUI(context, cubit),
            state is SettingsLoading
                ? LoadingScreenOverlay()
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildUI(BuildContext context, SettingsCubit cubit) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 20.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              onTap: () => cubit.pickImage(),
              child: cubit.isImageEdited
                  ? RoundedImageFile(
                      radius: 100,
                      image: cubit.imageFile,
                      isGroup: cubit.isGroupSettings,
                    )
                  : RoundedImageNetwork(
                      radius: 100,
                      imageUrl: cubit.currentSubject?.imageUrl,
                      isGroup: cubit.isGroupSettings,
                    ),
            ),
            SizedBox(height: 30.h),

            Form(
              key: cubit.formKey,
              child: MyTextformField(
                label: 'Name',
                controller: cubit.nameController,
                validator: cubit.isGroupSettings
                    ? TextFieldValidator.validateNotEmpty
                    : TextFieldValidator.validateName,
              ),
            ),
            SizedBox(height: 20.h),
            MyElevatedButton(
              label: 'Update data',
              onPressed: cubit.isUpdateable
                  ? () {
                      cubit.updateUserData();
                    }
                  : null,
            ),
            SizedBox(height: 20.h),
            MyElevatedButton(
              label: 'Reset',
              color: Colors.blueAccent,
              onPressed: cubit.isResetable
                  ? () {
                      cubit.loadSettings();
                    }
                  : null,
            ),
            SizedBox(height: 20.h),
            ...cubit.isGroupSettings
                ? [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Group Members:',
                        style: AppTextStyles.f18w600primary(),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cubit.chatModel!.membersModels.length,
                      itemBuilder: (context, index) {
                        final member = cubit.chatModel!.membersModels[index];
                        return UserListTile(
                          userModel: member,
                          onTap: () {},
                          isSelected: false,
                        );
                      },
                    ),
                  ]
                : [SizedBox.shrink()],
          ],
        ),
      ),
    );
  }
}
