import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;

  const ReactionPicker({super.key, required this.onReactionSelected});

  @override
  Widget build(BuildContext context) {
    final reactions = ['👍', '❤️', '😂', '😯', '😢', '🙏'];

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: reactions.map((reaction) {
          return GestureDetector(
            onTap: () => onReactionSelected(reaction),
            child: Text(reaction, style: TextStyle(fontSize: 28.sp)),
          );
        }).toList(),
      ),
    );
  }
}
