import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/rounded_image.dart';

class UserListTile extends StatelessWidget {
  final UserModel userModel;
  final bool isSelected;
  final void Function() onTap;
  const UserListTile({
    super.key,
    required this.userModel,
    required this.onTap,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      leading: RoundedImageNetwork(radius: 30, imageUrl: userModel.imageUrl),
      title: Text(userModel.name, style: AppTextStyles.f14w600primary()),
      onTap: onTap,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.accentColor, size: 24.r)
          : null,

      shape: Border.all(
        color: isSelected ? AppColors.accentColor : Colors.transparent,
      ),
    );
  }
}
