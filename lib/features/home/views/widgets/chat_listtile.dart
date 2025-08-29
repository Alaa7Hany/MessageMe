import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/chat_model_presenter.dart';
import 'package:message_me/core/services/dependency_injection_service.dart';
import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/core/widgets/rounded_image.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/chat_model.dart';

class ChatListtile extends StatelessWidget {
  final ChatModel chatModel;
  const ChatListtile({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    final String currentUid = getIt<AuthCubit>().currentUser!.uid;
    return ListTile(
      leading: Stack(
        children: [
          chatModel.getChatImageUrl(currentUid) != null &&
                  chatModel.getChatImageUrl(currentUid) != ''
              ? RoundedImageNetwork(
                  radius: 30,
                  imageUrl: chatModel.getChatImageUrl(currentUid)!,
                )
              : RoundedImageFile(radius: 30, isGroup: chatModel.isGroup),
          Positioned(
            bottom: 0,
            right: 0,
            child: chatModel.isActive(currentUid)
                ? Container(
                    height: 16.r,
                    width: 16.r,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.scaffoldBackground,
                        width: 2.r,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
      title: Text(
        chatModel.getChatTitle(currentUid),
        style: AppTextStyles.f16w500primary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chatModel.subtitle,
        style: AppTextStyles.f14w400secondary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        chatModel.formattedLastActive,
        style: AppTextStyles.f12w400secondary(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
