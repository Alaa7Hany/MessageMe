import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/my_snackbar.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../logic/chats_cubit/chats_cubit.dart';

import '../../logic/chats_cubit/chats_state.dart';
import '../widgets/chat_listtile.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocConsumer<ChatsCubit, ChatsState>(
          listener: (context, state) {
            if (state is ChatsError) {
              MySnackbar.error(context, state.message);
            }
          },
          builder: (context, state) {
            // MyLogger.bgBlue('ChatsPage, Building ChatsPage');
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: state is ChatsLoaded
                  ? state.chats.isNotEmpty
                        ? ListView.builder(
                            itemCount: state.chats.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => context.pushNamed(
                                  Routes.messages,
                                  arguments: state.chats[index],
                                ),
                                child: ChatListtile(
                                  chatModel: state.chats[index],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No Messages Yet!🤔\nsearch for your friends in the Users tab 👉',
                              style: AppTextStyles.f24w700primary(),
                              textAlign: TextAlign.center,
                            ),
                          )
                  : state is ChatsError
                  ? Center(
                      child: Text(
                        'Something went wrong',
                        style: AppTextStyles.f16w500primary(),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentColor,
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
