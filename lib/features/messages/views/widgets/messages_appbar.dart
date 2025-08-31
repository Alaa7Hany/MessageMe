import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/chat_model_presenter.dart';

import '../../../../core/services/dependency_injection_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/rounded_image.dart';
import '../../../auth/logic/auth_cubit/auth_cubit.dart';
import '../../../home/data/models/chat_model.dart';

class MessagesAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MessagesAppbar({
    super.key,
    required this.chatModel,
    required this.context,
    this.onTap,
  });

  final ChatModel chatModel;
  final BuildContext context;
  final void Function()? onTap;
  @override
  Size get preferredSize => Size.fromHeight(55.h);

  @override
  Widget build(BuildContext context) {
    final String currentId = getIt<AuthCubit>().currentUser!.uid;
    return AppBar(
      toolbarHeight: 55.h,
      centerTitle: true,
      title: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            chatModel.getChatImageUrl(currentId) != null &&
                    chatModel.getChatImageUrl(currentId) != ''
                ? RoundedImageNetwork(
                    radius: 25,
                    imageUrl: chatModel.getChatImageUrl(currentId)!,
                  )
                : RoundedImageFile(radius: 25, isGroup: chatModel.isGroup),
            SizedBox(width: 8.0.w),
            Expanded(
              child: Text(
                chatModel.getChatTitle(currentId),
                style: AppTextStyles.f18w600primary(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      foregroundColor: AppColors.accentColor,
      actionsPadding: EdgeInsets.zero,
      backgroundColor: AppColors.appBarBackground,
      leadingWidth: 35.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24.w),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
