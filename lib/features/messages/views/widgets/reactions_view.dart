import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';

class ReactionsView extends StatelessWidget {
  final Map<String, String> reactions;
  const ReactionsView({super.key, required this.reactions});

  @override
  Widget build(BuildContext context) {
    // Group reactions by emoji and count them
    final reactionCounts = <String, int>{};
    for (var reaction in reactions.values) {
      reactionCounts[reaction] = (reactionCounts[reaction] ?? 0) + 1;
    }

    // Sort reactions to show the most popular ones first
    final sortedReactions = reactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            sortedReactions
                .map(
                  (entry) => Text(
                    // Show count only if it's more than 1
                    '${entry.key}${entry.value > 1 ? entry.value : ''}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                )
                .expand((widget) => [widget, SizedBox(width: 4.w)])
                .toList()
              // This clever trick removes the last SizedBox
              ..removeLast(),
      ),
    );
  }
}
