import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/my_elevated_button.dart';
import '../../../../core/widgets/my_snackbar.dart';
import '../widgets/user_listtile.dart';

import '../../../../core/routing/routes.dart';
import '../../logic/find_users_cubit/find_users_cubit.dart';
import '../../logic/find_users_cubit/find_users_state.dart';
import '../widgets/search_field.dart';

class FindUsersPage extends StatelessWidget {
  const FindUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindUsersCubit, FindUsersState>(
      listener: (context, state) {
        if (state is FindUsersLoading) {
        } else if (state is FindUsersError) {
          MySnackbar.error(context, state.message);
        } else if (state is FindUsersStartChat) {
          context.pushNamed(Routes.messages, arguments: state.chatModel);
          context.read<FindUsersCubit>().emitLoadedUsers();
        }
      },
      builder: (context, state) {
        return _buildUI(context, state);
      },
    );
  }

  Widget _buildUI(BuildContext context, FindUsersState state) {
    if (state is FindUsersLoaded) {
      return Stack(
        children: [
          // Positioned(child: AuthButton(label: 'Start Chat')),
          Column(
            children: [
              SearchField(
                controller: context
                    .read<FindUsersCubit>()
                    .searchFieldController,
              ),
              SizedBox(height: 12.0.h),
              state.users.isEmpty && !state.isSearching
                  ? Expanded(
                      child: Center(
                        child: Text(
                          'No Friend, Huh☹️',
                          style: AppTextStyles.f24w700primary(),
                        ),
                      ),
                    )
                  : state.isSearching
                  ? Expanded(child: Center(child: CircularProgressIndicator()))
                  : Expanded(
                      child: ListView.builder(
                        controller: context
                            .read<FindUsersCubit>()
                            .usersScrollController,
                        itemCount:
                            state.users.length + (state.hasMoreUsers ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.users.length) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final user = state.users[index];
                          return UserListTile(
                            userModel: user,
                            isSelected: state.selectedUsers.contains(user),
                            onTap: () {
                              if (!state.selectedUsers.contains(user)) {
                                context.read<FindUsersCubit>().selectUser(user);
                              } else {
                                context.read<FindUsersCubit>().unselectUser(
                                  user,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: state.selectedUsers.isNotEmpty ? 20.h : -100.h,
            left: 20.w,
            right: 20.w,
            child: MyElevatedButton(
              label: state.selectedUsers.length == 1
                  ? 'Start Chat With ${state.selectedUsers.first.name}'
                  : 'Start Chat With ${state.selectedUsers.map((user) => user.name.split(' ').first).join(', ')}',
              onPressed: () {
                context.read<FindUsersCubit>().startChat();
              },
            ),
          ),
        ],
      );
    } else if (state is FindUsersError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
